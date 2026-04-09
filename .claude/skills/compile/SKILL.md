---
name: compile
description: "raw/ 자료를 wiki/로 컴파일하는 지식 그래프 빌드 파이프라인. 사용자가 컴파일, compile, 자료 정리해줘, 새 자료 반영해줘, raw 처리해줘 등을 말하거나, raw/에 새 파일을 넣었다고 언급할 때 이 스킬을 사용한다."
---

# Compile

raw/ 자료를 wiki/로 변환하는 전체 파이프라인.

## 사전 조건

- `wiki/index.md`가 존재하지 않으면 빈 틀로 생성한다.
- `_compile_log.md`가 비어있으면 `# Compile Log` 헤더만 추가한다 (기존 내용은 절대 교체하지 않는다).

## 언어 규칙 (모든 단계에 적용)

wiki/ 안에서 **기계가 매칭하는 값**은 전부 kebab-case 영어로 통일한다. 한글은 사람이 읽는 곳에만 쓴다.

| 항목 | 언어 | 예시 |
| --- | --- | --- |
| 파일명 | kebab-case 영어 | `pressure-angle.md` |
| frontmatter `topic`, `concepts` | kebab-case 영어 | `concepts: [pressure-angle, involute-curve]` |
| `[[wiki links]]` 링크 타깃 | kebab-case 영어 | `[[pressure-angle]]` 또는 `[[pressure-angle|압력각]]` |
| frontmatter `aliases` | 한글 허용 | `aliases: [압력각, pressure angle]` |
| 본문 내용 | 한글 허용 | 자연어 설명 |

파일명 충돌 방지: source는 서술적(`involute-curve-fundamentals`), concept는 개념명(`involute-curve`), synthesis는 주제명(`gear-design-overview`)으로 구분한다.

## 불변 조건 (깨지면 컴파일 미완료)

- source/concept/synthesis에 박힌 **모든 `[[link]]`는 저장 시점에 타깃 파일이 이미 존재해야 한다.**
- broken link가 하나라도 있으면 컴파일 완료로 판정하지 않는다.
- 이 조건을 지키기 위해 **concept-first 순서**로 처리한다 (step 4 참고).

## 실행 절차

### 1. 상태 파악

`_compile_log.md`를 읽어서 기존 컴파일 기록을 파악한다.

### 2. 변경 감지

`raw/` 디렉토리를 스캔하고, 각 파일의 sha256 해시를 계산한다. `raw/assets/`는 제외한다.

```bash
shasum -a 256 raw/<filename>
```

또는 변경 감지 스크립트를 사용한다:

```bash
.claude/skills/compile/scripts/detect-changes.sh
```

`_compile_log.md`에 기록된 해시와 비교:

- 해시가 없는 파일 → **신규**
- 해시가 다른 파일 → **변경됨**
- 해시가 같은 파일 → **스킵**

### 3. 처리 범위 결정

- **3개 이하** → 한 세션에서 모두 처리
- **4개 이상** → 파일 하나씩 순차 처리 (파일마다 로그 기록)

컨텍스트가 부족해지면 현재 파일까지 로그 기록 후 사용자에게 `/compile` 재실행을 안내한다.

### 4. 소스 페이지 + 개념 생성/갱신 (concept-first)

source 하나를 처리할 때마다 아래 단계를 **순서대로 모두 완료한 뒤** 다음 source로 넘어간다. **순서를 섞지 않는다** — 각 단계는 이전 단계가 끝나야만 안전하게 실행 가능하다.

#### 4-1. 개념 목록 추출 (메모리)

raw 파일을 읽고, 본문에 등장하는 핵심 개념을 kebab-case 영어로 나열한다. 아직 어떤 파일도 만들지 않는다. 이 단계의 출력은 메모리상의 리스트다.

예: `[pressure-angle, involute-curve, base-circle, pitch-circle]`

#### 4-2. 인덱스 대조

`wiki/index.md`와 `wiki/concepts/`의 기존 concept 파일들(aliases 포함)을 읽는다. step 4-1의 각 개념에 대해:

- **재사용**: 이미 존재하는 concept (aliases 매칭 포함) → 그 이름을 그대로 쓴다. 새로 만들지 않는다.
- **신규 생성**: 존재하지 않는 concept → 신규 생성 대상으로 마킹한다.

이 단계의 출력: `재사용 리스트` + `신규 생성 리스트`.

#### 4-3. 신규 concept 파일 먼저 생성

`신규 생성 리스트`의 각 항목에 대해 `wiki/concepts/<name>.md`를 **즉시 생성**한다. 내용은 최소한이어도 된다:

- frontmatter: `type: concept`, `topic` (해당 source의 topic 재사용), `aliases` (한글/영문)
- 본문: 한 줄 정의라도. 상세화는 나중에 보강 가능.

이 단계가 끝나면 step 4-4에서 사용할 모든 concept 파일이 디스크에 존재한다.

#### 4-4. source 페이지 생성

`wiki/sources/`에 source 페이지를 작성한다.

- frontmatter에 `type`, `topic`, `concepts`, `source_file`, `updated`, `checksum` 포함
- 본문은 원문을 그대로 옮기지 않는다. 핵심 주장/데이터/구조를 불릿 중심의 밀도 높은 요약으로 작성
- 개념 위치에 `[[wiki links]]` 삽입 — step 4-2에서 결정한 이름 그대로 사용
- **이 시점에 모든 링크 타깃은 이미 파일로 존재한다** (step 4-3에서 생성)
- raw 파일이 이미지를 참조하면 `![[filename.png]]` 형식으로 보존

#### 4-5. 검증

방금 생성한 source와 concept 파일에 대해 검증 스크립트를 실행한다. FAIL이 출력되면 해당 파일을 수정한 뒤 다시 실행한다:

```bash
.claude/skills/compile/scripts/validate.sh wiki/sources/<source>.md wiki/concepts/<concept1>.md wiki/concepts/<concept2>.md
```

### 5. 교차 개념 보강 (선택적)

2개 이상의 source에서 반복 등장하지만 아직 concept가 없는 용어를 추가 식별한다. 있으면 concept를 만들고 source에 링크를 삽입한다. 없으면 스킵.

### 6. Synthesis 생성/갱신

모든 source의 frontmatter `topic`을 수집하여 topic별 source 수를 센다:

```bash
grep -r '^topic:' wiki/sources/ | sed 's/.*topic: //'
```

1. topic별 source가 충분히 모였을 때(일반적으로 3개 이상) → 해당 topic의 synthesis가 없으면 `wiki/syntheses/`에 새로 생성한다.
2. 기존 synthesis에 새 source가 추가된 경우 → 갱신한다.
3. 생성/갱신 수가 0이어도 정상이다.

### 7. 인덱스 갱신

`wiki/`의 실제 파일 목록을 수집하고 `wiki/index.md`와 대조하여 동기화한다:

```bash
ls wiki/sources/ wiki/concepts/ wiki/syntheses/
```

### 8. 로그 기록

`_compile_log.md`에 한 줄씩 append한다:

```
## [2026-04-06] new | raw/filename.md → wiki-page-name | sha256:abc123...
```

### 9. 최종 검증

wiki/ 전체에서 `[[wiki links]]`를 추출하고, 타깃 파일 존재 여부를 확인한다:

```bash
grep -roh '\[\[[^]]*\]\]' wiki/ | sort -u
```

- 존재하지 않는 타깃 → concept를 생성하거나 링크를 제거한다.
- **누락이 0개여야 컴파일 완료로 판정한다.**

### 10. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.
