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
- 이 조건을 지키기 위해 **concept-first 순서**로 처리한다 (step 2 참고).

## 실행 절차

### 1. 상태 파악 및 변경 감지

`_compile_log.md`를 읽어 기존 컴파일 기록을 파악한다. `raw/` 디렉토리를 스캔하고, 각 파일의 sha256 해시를 계산한다 (`raw/assets/` 제외).

```bash
.claude/skills/compile/scripts/detect-changes.sh
```

출력:

- `NEW raw/<file> <hash>` — 로그에 없는 파일
- `CHANGED raw/<file> <hash>` — 해시가 다른 파일
- 해시가 같으면 스킵 (출력 없음)

### 2. 파일별 처리 루프 (per-file, concept-first)

파일 개수와 무관하게 파일 하나를 완전히 끝낸 뒤 다음 파일로 넘어간다. 배치 처리하지 않는다.

각 파일에 대해 2-1 ~ 2-7을 순서대로 실행한다.

#### 2-1. 개념 목록 추출

raw 파일을 읽고, 본문에 등장할 핵심 개념을 kebab-case 영어로 나열한다. 파일을 만들지 않고 리스트만 작성한다.

예: `[pressure-angle, involute-curve, base-circle, pitch-circle]`

#### 2-2. 인덱스 대조

`wiki/index.md`와 `wiki/concepts/`의 기존 concept 파일들(aliases 포함)을 읽는다. 2-1의 각 개념에 대해:

- **재사용**: 이미 존재하는 concept (aliases 매칭 포함) → 그 이름을 그대로 쓴다
- **신규 생성**: 존재하지 않는 concept → 신규 생성 리스트에 추가

#### 2-3. 신규 concept 파일 먼저 생성

신규 생성 리스트의 각 항목에 대해 `wiki/concepts/<name>.md`를 즉시 생성한다. 내용은 최소한이어도 된다:

- frontmatter: `type: concept`, `topic` (해당 source의 topic 재사용), `aliases` (한글/영문)
- 본문: 한 줄 정의라도

이 단계가 끝나면 2-4에서 사용할 모든 concept 파일이 디스크에 존재한다.

#### 2-4. source 페이지 생성

**source 파일명 결정** (원본 파일명이 아니라 내용 기반):

- **신규 파일 (new)**: 내용의 주제를 kebab-case 영어로 서술적 이름으로 짓는다. concept 이름과 구분되도록 한 단어 이상 덧붙인 서술형을 사용한다.
  - 예: concept `involute-curve` ↔ source `involute-curve-fundamentals`
  - 예: concept `profile-shift` ↔ source `profile-shift-verification`

- **변경된 파일 (updated)**: 새로 이름을 짓지 말고 **기존 source 파일명을 재사용한다.** 이유: LLM이 재컴파일 때마다 다른 이름을 지으면 같은 raw 파일에 대해 중복 source가 생긴다. `_compile_log.md`에서 기존 매핑을 먼저 찾는다:

  ```bash
  grep "raw/<filename>" _compile_log.md | tail -1
  ```

  출력 예시: `## [2026-04-08] new | raw/01-인볼류트-곡선.md → involute-curve-fundamentals | sha256:...`

  화살표 뒤의 `involute-curve-fundamentals`를 그대로 source 파일명으로 사용한다.

**페이지 작성**:

- `wiki/sources/<결정된-이름>.md`에 작성
- frontmatter: `type`, `topic`, `concepts`, `source_file`, `updated`, `checksum`
- 본문: 원문을 그대로 옮기지 않고 핵심 주장/데이터/구조를 불릿 중심으로 요약
- 개념 위치에 `[[wiki links]]` 삽입 — 2-2에서 결정한 이름 그대로 사용
- 이 시점에 모든 링크 타깃은 이미 파일로 존재한다 (2-3에서 생성)
- raw가 이미지를 참조하면 `![[filename.png]]` 형식으로 보존

#### 2-5. 검증

방금 생성한 source와 concept 파일에 대해 검증 스크립트를 실행한다. FAIL이 출력되면 수정 후 재실행:

```bash
.claude/skills/compile/scripts/validate.sh wiki/sources/<source>.md wiki/concepts/<concept1>.md wiki/concepts/<concept2>.md
```

#### 2-6. 로그 기록 (checkpoint)

`_compile_log.md`에 한 줄 append한다:

```
## [2026-04-09] new | raw/filename.md → wiki-page-name | sha256:abc123...
## [2026-04-09] updated | raw/other.md → other-page | sha256:def456...
```

- 신규 파일: `new`
- 변경된 파일: `updated`

이 append가 완료된 시점이 재시작 가능한 checkpoint다.

#### 2-7. 진행 보고

`[N/total] filename.md → wiki-page-name` 한 줄 출력 후 다음 파일로.

**컨텍스트 부족 대비**: 컨텍스트가 부족해지면 현재까지 처리한 개수를 보고하고 세션을 종료한다. `/compile`을 다시 실행하면 `detect-changes.sh`가 처리된 파일을 자동 스킵하므로 남은 것만 이어서 처리된다.

### 3. 후처리 (post-loop, 모든 파일 완료 후 1회)

#### 3-1. 교차 개념 보강 (선택적)

2개 이상의 source에서 반복 등장하지만 아직 concept가 없는 용어를 추가 식별한다. 있으면 concept를 만들고 source에 링크를 삽입한다. 없으면 스킵.

#### 3-2. Synthesis 생성/갱신

모든 source의 frontmatter `topic`을 수집하여 topic별 source 수를 센다:

```bash
grep -r '^topic:' wiki/sources/ | sed 's/.*topic: //'
```

- topic별 source가 충분히 모였을 때(일반적으로 3개 이상) → 해당 topic의 synthesis가 없으면 `wiki/syntheses/`에 새로 생성
- 기존 synthesis에 새 source가 추가된 경우 → 갱신
- 생성/갱신 수가 0이어도 정상

#### 3-3. 인덱스 갱신

`wiki/`의 실제 파일 목록을 수집하고 `wiki/index.md`와 대조하여 동기화한다:

```bash
ls wiki/sources/ wiki/concepts/ wiki/syntheses/
```

#### 3-4. 최종 검증

wiki/ 전체에서 `[[wiki links]]`를 추출하고, 타깃 파일 존재 여부를 확인한다:

```bash
grep -roh '\[\[[^]]*\]\]' wiki/ | sort -u
```

- 존재하지 않는 타깃 → concept를 생성하거나 링크를 제거한다
- 누락이 0개여야 컴파일 완료로 판정한다

#### 3-5. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.
