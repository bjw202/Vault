---

## name: compile description: "raw/ 자료를 wiki/로 컴파일하는 지식 그래프 빌드 파이프라인. 사용자가 '컴파일', '컴파일 해줘', 'compile', '자료 정리해줘', '새 자료 반영해줘', 'raw 처리해줘' 등을 말하거나, raw/에 새 파일을 넣었다고 언급할 때 이 스킬을 사용한다."

# Compile

raw/ 자료를 wiki/로 변환하는 전체 파이프라인.

## 사전 조건

- `wiki/index.md`가 존재하지 않으면 빈 틀로 생성한다.
- `_compile_log.md`가 비어있으면 `# Compile Log` 헤더만 추가한다 (기존 내용은 절대 교체하지 않는다).

## 실행 절차

### 1. 상태 파악

`_compile_log.md`를 읽어서 기존 컴파일 기록을 파악한다.

### 2. 변경 감지

`raw/` 디렉토리를 스캔하고, 각 파일의 sha256 해시를 계산한다. `raw/assets/`는 이미지/첨부파일 폴더이므로 소스 컴파일 대상에서 제외한다.

```bash
shasum -a 256 raw/<filename>
```

`_compile_log.md`에 기록된 해시와 비교:

- 해시가 없는 파일 → **신규**
- 해시가 다른 파일 → **변경됨**
- 해시가 같은 파일 → **스킵**

### 3. 처리 범위 결정

- **3개 이하** → 한 세션에서 모두 처리
- **4개 이상** → 파일 하나씩 순차 처리 (파일마다 로그 기록)

컨텍스트가 부족해지면 현재 파일까지 로그 기록 후 사용자에게 `/compile` 재실행을 안내한다.

### 4. 소스 페이지 파일명 결정

kebab-case 영어로 정규화한다 (`삼성전자 분석.md` → `samsung-analysis.md`).

### 5. 소스 페이지 생성/갱신

raw/는 원본 보관소(source of truth)이고, wiki/는 LLM이 컴파일한 지식 계층이다. 소스 페이지는 원문 복사가 아니라 **핵심 클레임을 추출·요약·구조화한 컴파일 결과물**이다.

1. `wiki/sources/`에 source 페이지를 생성하거나 갱신한다.
2. frontmatter에 `type`, `topic`, `concepts`, `source_file`, `updated`, `checksum`을 포함한다.
3. 본문은 원문을 그대로 옮기지 않는다. 핵심 주장, 데이터, 구조를 추출하여 불릿 중심의 밀도 높은 요약으로 작성한다.
4. 개념 추출 및 링크 삽입: a. 본문 작성 완료 후, 이 source에서 등장하는 **핵심 개념/용어/패턴**을 5개 이상 나열한다. b. 각 개념에 대해 `wiki/index.md`의 Concepts 섹션을 확인한다:
   - 기존 concept가 있으면 → `[[기존-concept-이름]]`으로 링크
   - 기존 concept가 없으면 → `[[새-concept-이름]]`으로 링크를 **반드시 삽입한다** (페이지가 아직 없어도 링크를 건다) c. 관련 source 페이지도 `[[source-이름]]`으로 연결한다.
5. raw 파일이 이미지를 참조하면 wiki 페이지에서도 `![[filename.png]]` 형식으로 보존한다.
6. 원문이 필요하면 `raw/`에서 직접 읽는다 — wiki에 원문을 중복 보관하지 않는다.

### 6. 링크 수집 (Step 5 → 6 연결)

Step 5에서 생성한 source 페이지들을 **모두 다시 읽어서** 본문에 삽입된 `[[wiki links]]`를 전수 수집한다.

```bash
grep -roh '\[\[[^]]*\]\]' wiki/sources/ | sort -u
```

수집된 링크 목록과 `wiki/index.md`의 기존 페이지 목록을 대조하여:

- **이미 존재** → 스킵
- **존재하지 않음** → Step 7에서 생성 대상으로 등록

이 단계는 LLM의 기억에 의존하지 않고 **파일 시스템에서 기계적으로 추출**하므로 누락이 발생하지 않는다.

### 7. 개념 연결 및 생성

두 가지 입력을 결합하여 concept 생성 대상을 결정한다:

**입력 A**: Step 6에서 수집한 "존재하지 않는 링크 타깃" 목록.

**입력 B**: Step 5에서 생성/갱신한 source 페이지의 본문을 직접 분석하여, `[[wiki links]]`로 표현되지 않았지만 concept로 분리할 가치가 있는 개념을 추가 식별한다. 판단 기준:

- 2개 이상의 source에서 반복 등장하는 용어
- 독립적 정의가 가능한 전문 용어/패턴/프레임워크

입력 A + 입력 B를 합쳐서 중복 제거한 뒤, 각각을 처리한다:

1. `wiki/index.md`의 Concepts 섹션과 기존 concept의 aliases를 확인하여, 이름만 다른 같은 개념이 있으면 source 페이지의 링크를 기존 concept로 수정한다.
2. 기존 concept에 해당하지 않으면 `wiki/concepts/`에 새로 만든다.
3. 처리 후 누락된 링크 타깃이 0개인지 다시 확인한다.
4. 입력 B에서 발견하여 새로 생성한 concept가 있으면, 해당 개념이 등장하는 source 페이지에 `[[concept-이름]]` 링크를 삽입한다.

### 8. Synthesis 생성/갱신

모든 source 페이지의 frontmatter `topic` 필드를 수집하여 topic별 source 수를 기계적으로 센다:

```bash
grep -r '^topic:' wiki/sources/ | sed 's/.*topic: //'
```

1. topic별 source 수를 카운팅한다.
2. **3개 이상인 topic**을 추출하고, 해당 topic에 대한 synthesis가 `wiki/syntheses/`에 있는지 `ls`로 확인한다.
3. synthesis가 없는 topic → `wiki/syntheses/`에 **새로 생성한다**. 관련 source 페이지들을 읽고 통합 분석을 작성한다.
4. 기존 synthesis가 있지만 새 source가 추가된 경우 → 기존 synthesis를 **갱신한다**.
5. 생성/갱신한 synthesis 수가 0이어도 정상이다 (topic당 source가 3개 미만이면).

### 9. 인덱스 갱신

`wiki/`의 실제 파일 목록을 기계적으로 수집한다:

```bash
ls wiki/sources/ wiki/concepts/ wiki/syntheses/
```

`wiki/index.md`의 각 섹션과 대조하여:

- 파일은 있는데 index에 없음 → index에 추가
- index에 있는데 파일이 없음 → index에서 제거

### 10. 로그 기록

`_compile_log.md`에 한 줄씩 append한다:

```
## [2026-04-06] new | raw/filename.md → wiki-page-name | sha256:abc123...
```

### 11. 최종 검증

wiki/ 전체에서 `[[wiki links]]`를 추출하고, 타깃 파일 존재 여부를 일괄 확인한다:

```bash
grep -roh '\[\[[^]]*\]\]' wiki/ | sort -u
```

수집된 링크 타깃 각각에 대해 `wiki/sources/`, `wiki/concepts/`, `wiki/syntheses/`에 해당 파일이 있는지 확인한다.

- 존재하지 않는 타깃 → concept 페이지를 생성하거나 링크를 제거한다.
- **누락이 0개여야 컴파일 완료로 판정한다.**

### 12. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.

## 주의사항

- `[[wiki links]]`를 사용하여 페이지 간 연결을 만든다.
- 출처가 불명확하면 "출처 미확인"으로 명시한다.
- 개념 이름은 기존 `wiki/index.md`의 표기를 따른다.