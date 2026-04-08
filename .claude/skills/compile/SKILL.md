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

### 4. 파일명 규칙 (모든 wiki 페이지 공통)

wiki/ 아래 모든 파일(source, concept, synthesis)의 파일명은 **kebab-case 영어**로 정규화한다. 한글 파일명은 절대 사용하지 않는다.

- `삼성전자 분석.md` → `samsung-analysis.md`
- `인볼류트 곡선.md` → `involute-curve.md`
- `포락선 이론.md` → `envelope-theory.md`

이 규칙은 source, concept, synthesis 모두 동일하게 적용된다. `[[wiki links]]`의 링크 타깃도 이 kebab-case 영어 이름을 사용한다. 한글 표기는 frontmatter의 `aliases` 필드에 보존한다.

**파일명 충돌 방지**: Obsidian의 `[[wiki links]]`는 폴더와 무관하게 파일명으로만 해석되므로, sources/와 concepts/와 syntheses/ 사이에 동일한 파일명이 존재하면 링크가 모호해진다. 이를 방지하기 위해:
- source 파일명: 원문의 주제를 서술적으로 (`involute-curve-fundamentals.md`, `gear-basic-parameters.md`)
- concept 파일명: 개념 자체의 이름 (`involute-curve.md`, `gear-module.md`)
- synthesis 파일명: 통합 분석의 주제 (`gear-design-overview.md`)
- 새 파일 생성 전에 다른 폴더에 같은 이름의 파일이 없는지 확인한다.

### 5. 소스 페이지 + 개념 생성/갱신

raw/는 원본 보관소(source of truth)이고, wiki/는 LLM이 컴파일한 지식 계층이다. 소스 페이지는 원문 복사가 아니라 **핵심 클레임을 추출·요약·구조화한 컴파일 결과물**이다.

source 하나를 처리할 때마다 아래 절차를 **모두 완료한 뒤** 다음 source로 넘어간다:

1. `wiki/sources/`에 source 페이지를 생성하거나 갱신한다.
2. frontmatter에 `type`, `topic`, `concepts`, `source_file`, `updated`, `checksum`을 포함한다.
3. 본문은 원문을 그대로 옮기지 않는다. 핵심 주장, 데이터, 구조를 추출하여 불릿 중심의 밀도 높은 요약으로 작성한다.
4. 개념 추출 및 링크 삽입: a. 본문 작성 완료 후, 이 source에서 등장하는 **핵심 개념/용어/패턴**을 5개 이상 나열한다. b. 각 개념에 대해 `wiki/index.md`의 Concepts 섹션을 확인한다:
   - 기존 concept가 있으면 → `[[기존-concept-이름]]`으로 링크
   - 기존 concept가 없으면 → `[[새-concept-이름]]`으로 링크를 삽입한다. c. 관련 source 페이지도 `[[source-이름]]`으로 연결한다.
5. raw 파일이 이미지를 참조하면 wiki 페이지에서도 `![[filename.png]]` 형식으로 보존한다.
6. 원문이 필요하면 `raw/`에서 직접 읽는다 — wiki에 원문을 중복 보관하지 않는다.
7. **concept 즉시 생성** — source 작성이 끝나면 바로 실행한다: a. 위 4단계에서 삽입한 `[[concept-이름]]` 링크 목록을 확인한다. b. 각 링크에 대해 `wiki/concepts/`에 해당 파일이 이미 있는지 확인한다. c. `wiki/index.md`의 Concepts 섹션과 기존 concept의 aliases도 확인하여, 이름만 다른 같은 개념이 있으면 source 페이지의 링크를 기존 concept로 수정한다. d. 기존 concept에 해당하지 않으면 `wiki/concepts/`에 즉시 새로 만든다. 파일명은 Step 4의 규칙과 동일하게 **kebab-case 영어**로 작성한다 (예: `압력각` → `pressure-angle.md`). 한글 표기는 frontmatter `aliases`에 보존한다. frontmatter에 `type: concept`, `topic`, `aliases`를 포함한다. e. 이미 존재하는 concept는 스킵한다.

이렇게 하면 source 하나의 처리가 끝날 때 관련 concept가 모두 존재하게 된다. 다음 source 작업 시 기존 concept를 자연스럽게 재사용할 수 있다.

### 6. 교차 개념 보강 (선택적)

Step 5에서 각 source와 함께 핵심 concept는 이미 생성되었다. 이 단계는 **보너스 패스**로, cross-source 분석을 통해 추가 concept를 식별한다:

- 2개 이상의 source에서 반복 등장하지만 아직 concept 페이지가 없는 용어
- 독립적 정의가 가능한 전문 용어/패턴/프레임워크

발견한 개념이 있으면:

1. `wiki/concepts/`에 새로 만든다.
2. 해당 개념이 등장하는 source 페이지에 `[[concept-이름]]` 링크를 삽입한다.

발견한 추가 개념이 없으면 이 단계를 스킵해도 된다.

### 7. Synthesis 생성/갱신

모든 source 페이지의 frontmatter `topic` 필드를 수집하여 topic별 source 수를 기계적으로 센다:

```bash
grep -r '^topic:' wiki/sources/ | sed 's/.*topic: //'
```

1. topic별 source 수를 카운팅한다.
2. **3개 이상인 topic**을 추출하고, 해당 topic에 대한 synthesis가 `wiki/syntheses/`에 있는지 `ls`로 확인한다.
3. synthesis가 없는 topic → `wiki/syntheses/`에 **새로 생성한다**. 관련 source 페이지들을 읽고 통합 분석을 작성한다.
4. 기존 synthesis가 있지만 새 source가 추가된 경우 → 기존 synthesis를 **갱신한다**.
5. 생성/갱신한 synthesis 수가 0이어도 정상이다 (topic당 source가 3개 미만이면).

### 8. 인덱스 갱신

`wiki/`의 실제 파일 목록을 기계적으로 수집한다:

```bash
ls wiki/sources/ wiki/concepts/ wiki/syntheses/
```

`wiki/index.md`의 각 섹션과 대조하여:

- 파일은 있는데 index에 없음 → index에 추가
- index에 있는데 파일이 없음 → index에서 제거

### 9. 로그 기록

`_compile_log.md`에 한 줄씩 append한다:

```
## [2026-04-06] new | raw/filename.md → wiki-page-name | sha256:abc123...
```

### 10. 최종 검증

wiki/ 전체에서 `[[wiki links]]`를 추출하고, 타깃 파일 존재 여부를 일괄 확인한다:

```bash
grep -roh '\[\[[^]]*\]\]' wiki/ | sort -u
```

수집된 링크 타깃 각각에 대해 `wiki/sources/`, `wiki/concepts/`, `wiki/syntheses/`에 해당 파일이 있는지 확인한다.

- 존재하지 않는 타깃 → concept 페이지를 생성하거나 링크를 제거한다.
- **누락이 0개여야 컴파일 완료로 판정한다.**

### 11. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.

## 주의사항

- `[[wiki links]]`를 사용하여 페이지 간 연결을 만든다.
- 출처가 불명확하면 "출처 미확인"으로 명시한다.
- 개념 이름은 기존 `wiki/index.md`의 표기를 따른다.