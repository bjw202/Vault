# CLAUDE.md 업그레이드 계획

> **기반 문서:** `docs/debate-2026-04-05T16-24-54.md` (Claude Code vs Codex CLI 4라운드 토론) **작성일:** 2026-04-06 **목표:** CLAUDE.md의 실제 운영 가능성 높이기 — 빠진 정의 채우고, Obsidian 설정 정리

---

## 현황 요약

| 뭐가 문제인가 | 상태 | 급한 정도 |
| --- | --- | --- |
| 초기 빌드 안 됨 | raw/ 8개인데 wiki/ 텅 빔 | 바로 해야 함 |
| "파일 바뀜" 기준 없음 | sha256 같은 기준 없이 LLM 감으로 판단 | 바로 해야 함 |
| Obsidian 설정 찌꺼기 | workspace.json에 예전 파일 경로 11개 남아있음 | 정리 필요 |
| `aliases` 필드 빠짐 | PROJECT_GUIDE.md에는 있는데 CLAUDE.md에 없음 | 추가 필요 |
| 그래프 뷰 밋밋함 | 색상 구분 없음, 화살표 꺼짐 | 있으면 좋음 |

> **참고:** `PROJECT_GUIDE.md`는 프로젝트 설명 문서이지 CLAUDE.md와 경쟁하는 규칙 문서가 아님. 병합/삭제 불필요.

---

## Phase 1: CLAUDE.md 빠진 정의 채우기

### 1-1. "파일이 바뀌었다"의 기준 정의

지금 CLAUDE.md에는 "materially changed" 라고만 적혀있고 기준이 없음.

**CLAUDE.md에 추가할 내용:**

```md
## Change Detection

파일이 "변경됨"인지는 sha256 체크섬으로 판단한다.
- `_compile_log.md`에 기록된 해시와 현재 파일 해시가 다르면 → 변경됨
- 해시가 없으면 → 신규 파일 취급
```

### 1-2. `_compile_log.md` 포맷 구체화

지금은 빈 헤더만 있음. 어떤 형식으로 기록할지 CLAUDE.md에 명시.

**CLAUDE.md에 추가할 내용:**

```md
`_compile_log.md` 각 엔트리에는 최소한 다음이 포함되어야 한다:

| date | source_file | sha256 | status | derived_pages | concepts_touched | notes |
|------|-------------|--------|--------|---------------|------------------|-------|
```

### 1-3. Required Metadata에 `aliases` 추가

개념 문서끼리 같은 걸 다른 이름으로 부를 때 합칠 수 있도록.

**CLAUDE.md 수정 — 기존 5개 필드에 추가:**

```md
- `type`
- `topic`
- `concepts`
- `aliases` (선택 — 같은 개념의 다른 이름들. concept 문서에서 권장)
- `source_file` or `sources`
- `updated`
- `checksum` (compile이 자동 기록, source 문서에만 해당)
```

### 1-4. `.system/` 인덱스가 뭘 담아야 하는지 명세

지금은 "인덱스를 두라"고만 하고 뭘 적어야 하는지 안 적혀있음.

**CLAUDE.md에 추가할 내용:**

```md
## System Index Structure

각 인덱스에는 최소한 다음이 포함되어야 한다:

- `master-index.md` — 전체 wiki 페이지 목록 (type별 분류)
- `concept-index.md` — 개념명 → 페이지 경로 + aliases (역방향 조회용)
- `source-index.md` — raw 파일명 → source 페이지 경로 + checksum
- `synthesis-index.md` — synthesis 페이지 + 연결된 source/concept 목록

인덱스는 compile할 때 같이 갱신해야 한다.
```

---

## Phase 2: Obsidian 설정 정리

### 2-1. `workspace.json` 유령 참조 제거

예전에 만들었다가 삭제한 파일 11개가 `lastOpenFiles`에 남아있음. 존재하지 않는 경로 제거.

### 2-2. `app.json` 필터 정리

`"_index.md"` 숨김 필터가 남아있는데 해당 파일이 이제 없음. 제거.

### 2-3. `graph.json` 시각화 개선

source/concept/synthesis를 색상으로 구분하고, 링크 방향 화살표 켜기.

```json
{
  "hideUnresolved": true,
  "showOrphans": false,
  "colorGroups": [
    {"query": "path:wiki/sources", "color": {"a": 1, "r": 68, "g": 138, "b": 255}},
    {"query": "path:wiki/concepts", "color": {"a": 1, "r": 255, "g": 165, "b": 0}},
    {"query": "path:wiki/syntheses", "color": {"a": 1, "r": 76, "g": 175, "b": 80}}
  ],
  "showArrow": true,
  "textFadeMultiplier": -0.5
}
```

---

## Phase 3: Claude Code 스킬 3개

| 스킬 | 하는 일 | 언제 쓰나 |
| --- | --- | --- |
| `/compile` | raw/ → wiki/ 변환 전체 과정 (해시 비교 → source 생성 → concept 연결 → 인덱스 갱신 → 로그 기록) | 새 자료 넣고 나서 |
| `/graph-lint` | 깨진 링크, 고아 문서, 중복 개념, 인덱스 동기화, Obsidian 설정 점검 | 구조 정리할 때 |
| `/bootstrap` | 초기 셋업 1회성 — .system/ 인덱스 생성, Obsidian 설정 정리, 전체 초기 컴파일 | 지금 당장 |

---

## 실행 순서

```
Phase 1 — CLAUDE.md 수정 (바로)
├── 변경 감지 기준 추가
├── _compile_log.md 포맷 명세
├── Required Metadata에 aliases, checksum 추가
└── .system/ 인덱스 구조 명세

Phase 2 — Obsidian 정리 (Phase 1과 병렬 가능)
├── workspace.json 유령 참조 제거
├── app.json 필터 정리
└── graph.json 시각화 설정

Phase 3 — 스킬 생성 (Phase 1 완료 후)
├── /compile
├── /graph-lint
└── /bootstrap → 실행해서 초기 빌드 완료
```

---

## 토론에서 나왔지만 지금은 안 하는 것들

| 제안 | 왜 안 하나 |
| --- | --- |
| `entity_id`, `claim_id`, `source_span` 등 7개 필드 | 아직 컴파일 한 건도 안 됨. 첫 빌드 후 재검토 |
| `canonical_id` 필드 | `aliases`로 충분 |
| `rag-query-planner` 별도 스킬 | CLAUDE.md에 이미 질의 순서 적혀있음. 스킬로 빼면 이중 관리 |
| `vault-preflight` 별도 스킬 | compile 시작 단계일 뿐. 따로 뺄 이유 없음 |
| `embedding_keywords` + keyword-index.json | 파일 100개 넘기 전엔 불필요 |
| `PROJECT_GUIDE.md` 삭제/병합 | 프로젝트 설명 문서이므로 그대로 유지 |
