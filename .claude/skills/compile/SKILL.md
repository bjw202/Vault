---
name: compile
description: "raw/ 자료를 wiki/로 컴파일하는 지식 그래프 빌드 파이프라인. 사용자가 '컴파일', '컴파일 해줘', 'compile', '자료 정리해줘', '새 자료 반영해줘', 'raw 처리해줘' 등을 말하거나, raw/에 새 파일을 넣었다고 언급할 때 이 스킬을 사용한다."
---

# Compile

raw/ 자료를 wiki/로 변환하는 전체 파이프라인.

## 사전 조건

- `wiki/index.md`가 존재하지 않으면 빈 틀로 생성한다.
- `_compile_log.md`가 비어있으면 `# Compile Log` 헤더만 추가한다 (기존 내용은 절대 교체하지 않는다).

## 실행 절차

### 1. 상태 파악

`_compile_log.md`를 읽어서 기존 컴파일 기록을 파악한다.

### 2. 변경 감지

`raw/` 디렉토리를 스캔하고, 각 파일의 sha256 해시를 계산한다.
`raw/assets/`는 이미지/첨부파일 폴더이므로 소스 컴파일 대상에서 제외한다.

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

raw/는 원본 보관소(source of truth)이고, wiki/는 LLM이 컴파일한 지식 계층이다.
소스 페이지는 원문 복사가 아니라 **핵심 클레임을 추출·요약·구조화한 컴파일 결과물**이다.

1. `wiki/sources/`에 source 페이지를 생성하거나 갱신한다.
2. frontmatter에 `type`, `topic`, `concepts`, `source_file`, `updated`, `checksum`을 포함한다.
3. 본문은 원문을 그대로 옮기지 않는다. 핵심 주장, 데이터, 구조를 추출하여 불릿 중심의 밀도 높은 요약으로 작성한다.
4. `[[wiki links]]`로 관련 concept/source를 연결한다.
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

Step 6에서 수집한 "존재하지 않는 링크 타깃" 목록을 하나씩 처리한다:

1. `wiki/index.md`의 Concepts 섹션과 기존 concept의 aliases를 확인하여, 이름만 다른 같은 개념이 있으면 source 페이지의 링크를 기존 concept로 수정한다.
2. 기존 concept에 해당하지 않으면 `wiki/concepts/`에 새로 만든다.
3. 처리 후 누락된 링크 타깃이 0개인지 다시 확인한다.

### 8. Synthesis 검토 및 생성

- 기존 synthesis 페이지에 영향이 있으면 갱신한다.
- 동일 주제 source가 3개 이상이고 관련 synthesis가 없으면 생성을 검토한다.
- synthesis가 0개인 topic이 있으면 사용자에게 생성 여부를 확인한다.

### 9. 인덱스 갱신

`wiki/index.md`를 갱신한다. Sources, Concepts, Syntheses 섹션을 실제 파일과 동기화한다.

### 10. 로그 기록

`_compile_log.md`에 한 줄씩 append한다:

```
## [2026-04-06] new | raw/filename.md → wiki-page-name | sha256:abc123...
```

### 11. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.

## 주의사항

- `[[wiki links]]`를 사용하여 페이지 간 연결을 만든다.
- 출처가 불명확하면 "출처 미확인"으로 명시한다.
- 개념 이름은 기존 `wiki/index.md`의 표기를 따른다.
