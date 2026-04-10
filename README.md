# Vault

LLM이 유지하는 개인 지식 그래프 시스템. [Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을 Claude Code 스킬로 구현한다.

자료를 넣으면 LLM이 자동으로 지식 그래프를 만들고, 유지하고, 질문에 답한다. 자료가 쌓일수록 위키가 풍부해지고, 답변이 다시 위키로 돌아간다.

## 왜 이 시스템인가 — Karpathy의 문제 제기

> "RAG는 retrieval과 generation만 한다. 지식이 **컴파일되지 않는다**." — Karpathy

일반적인 RAG는 질문을 받을 때마다 원본 문서에서 처음부터 답을 찾는다. 아무리 많이 질문해도 **지식이 쌓이지 않는다.** 같은 질문을 다음 달에 또 하면 벡터 검색은 또 처음부터 돈다.

Karpathy가 제안한 해법은 단순하다. 원본(`raw/`)과 질문 사이에 **사람도 읽을 수 있는 위키(`wiki/`)** 를 끼워 넣는 것. 위키는 LLM이 "프로그래머처럼" 계속 유지보수한다. 새 자료가 들어오면 요약을 만들고, 기존 페이지와 크로스레퍼런스를 엮고, 주기적으로 건강도를 점검한다.

- **지식이 축적된다.** 원본은 불변이지만 위키는 계속 좋아진다.
- **답변도 자산이 된다.** 좋은 답변은 `syntheses/`에 다시 들어간다.
- **사람이 검증 가능하다.** 위키는 마크다운 파일이라 Obsidian으로 그대로 읽고 고칠 수 있다. "LLM이 뭘 했는지" 추적이 쉽다.
- **인프라가 없다.** 벡터DB도, 그래프DB도 없다. 파일만 있으면 된다.

## 설계 철학 (Karpathy ↔ Vault 매핑)

| Karpathy 원칙 | Vault 구현 |
|---|---|
| 3 layers (raw / wiki / schema) | `raw/` → `wiki/` → `CLAUDE.md` |
| `index.md` 1개 | `wiki/index.md` |
| `log.md` 1개, append-only | `_compile_log.md` |
| 3 operations (ingest / query / lint) | `/compile`, `/query`, `/graph-lint` |
| Schema는 얇은 계약 | `CLAUDE.md` ~70줄 |
| "지식 베이스를 코드처럼 다룬다" | Obsidian = IDE, LLM = 프로그래머, wiki = 소스코드 |

## 3 × 3 × 3 구조

Vault는 세 가지가 모두 3개로 정리된다. CLAUDE.md의 규칙을 그대로 옮기면:

### 3 레이어

- **`raw/`** — 사용자가 넣는 원본 자료. **불변**. 마크다운/텍스트 + `raw/assets/`의 이미지.
- **`wiki/`** — LLM이 관리하는 지식 그래프. 이 안의 모든 파일은 LLM이 만들고 고친다.
- **`CLAUDE.md`** — 얇은 schema. LLM이 세션 시작할 때 읽는 규칙서.

### 3 객체 타입

| 객체 | 위치 | 역할 | 예시 |
|---|---|---|---|
| **Source** | `wiki/sources/` | 원본 1개 → 요약 카드 1개 (provenance 보존) | `gear-basic-parameters.md` |
| **Concept** | `wiki/concepts/` | 여러 Source에서 반복되는 개념. **메인 검색 레이어.** | `pressure-angle.md` |
| **Synthesis** | `wiki/syntheses/` | 여러 Source를 엮은 통합 분석. 질문 답변도 여기로 들어옴. | `gear-design-overview.md` |

### 3 연산

- **`/compile`** — raw → wiki 빌드
- **`/query`** — wiki → 답변
- **`/graph-lint`** — wiki 품질 점검

각각은 `.claude/skills/` 아래에 독립된 스킬로 들어있다.

## 디렉토리 구조

```
Vault/
├── raw/                    # 사용자가 넣는 원본 자료 (불변)
│   └── assets/             # 이미지, 다이어그램
├── wiki/                   # LLM이 관리하는 지식 그래프
│   ├── index.md            # 통합 인덱스 (모든 페이지 목록)
│   ├── sources/            # 원본 1:1 요약
│   ├── concepts/           # 재사용 가능한 개념
│   └── syntheses/          # 통합 분석 + 질문 답변
├── .claude/skills/         # 실행 절차 (스킬)
│   ├── compile/
│   │   ├── SKILL.md        # raw → wiki 컴파일 절차
│   │   └── scripts/
│   │       ├── detect-changes.sh  # sha256 기반 변경 감지
│   │       └── validate.sh        # 언어 규칙 + frontmatter 검증
│   ├── query/SKILL.md      # 지식 검색 + 재귀 탐색 + 답변 작성
│   ├── graph-lint/SKILL.md # 그래프 품질 점검 + 자동 수정
│   └── push/SKILL.md       # GitHub 푸시 (보조)
├── _compile_log.md         # 컴파일 이력 (append-only, sha256 포함)
└── CLAUDE.md               # 시스템 규칙 (얇은 schema)
```

## 빠른 시작

### 요구 사항

- [Claude Code](https://claude.ai/claude-code) (CLI 또는 데스크톱 앱)
- [Obsidian](https://obsidian.md) (선택 — wiki 탐색 및 그래프 뷰)

### 설치

```bash
# 1. 저장소 클론
git clone https://github.com/bjw202/Vault.git
cd Vault

# 2. 기본 디렉토리 생성
mkdir -p raw/assets wiki/sources wiki/concepts wiki/syntheses

# 3. 컴파일 로그 초기화
echo "# Compile Log" > _compile_log.md

# 4. 자료 넣기
cp ~/my-research/*.md raw/

# 5. Claude Code에서 컴파일
claude
# 프롬프트에서: 컴파일 해줘
```

## 일상적인 사용 흐름

Karpathy가 제안한 워크플로우는 이렇게 생겼다:

```
[새 자료] → /compile → [wiki 갱신]
                            ↓
[질문]   → /query   → [답변 + 좋은 답변은 synthesis로 저장]
                            ↓
[정기]   → /graph-lint → [깨진 링크·고아·중복 수선]
```

**예시 시나리오:**

```
# 월요일: 논문 3개를 raw/에 넣었다
raw/paper-a.md  raw/paper-b.md  raw/paper-c.md
→ /compile
→ concept 5개 생성, source 3개 생성, synthesis 1개 갱신

# 화요일: 질문
"이 세 논문에서 압력각 이론이 서로 모순되는 지점이 어디야?"
→ /query
→ wiki/index.md → 관련 페이지 재귀 탐색 → 대비표로 답변
→ 좋은 답변이라 synthesis로 저장 (wiki/syntheses/pressure-angle-contradictions.md)

# 주말: 정기 점검
→ /graph-lint
→ 깨진 링크 2개 자동으로 스텁 concept 생성
→ 고아 문서 3개 발견, 사용자에게 삭제 여부 질문
```

## 3 연산 상세

### 1. `/compile` — raw/ → wiki/

`raw/`의 자료를 읽고 `wiki/`에 사람이 읽을 수 있는 요약 카드 + 개념 페이지 + (필요하면) 통합 분석을 만든다.

**핵심 특징:**

- **sha256 기반 변경 감지.** 이미 컴파일한 파일은 자동 스킵. 바뀐 파일만 다시 처리.
- **파일 하나씩 순차 처리.** 배치 처리하지 않는다. 파일 완료마다 `_compile_log.md`에 한 줄이 찍히며 이게 재시작 가능한 **checkpoint**다. 컨텍스트가 부족해지면 `/compile`을 다시 실행해 남은 파일만 이어서 처리하면 된다.
- **concept-first 순서.** 개념 추출 → 인덱스 대조 → 신규 concept 파일 **먼저** 생성 → source 작성 + 링크 삽입. 이 순서 덕분에 `[[link]]`가 박히는 시점에 타깃 파일이 이미 존재한다. Broken link를 구조적으로 원천 차단.
- **언어 규칙.** 기계가 매칭하는 값(파일명, `topic`, `concepts`, 링크 타깃)은 전부 kebab-case 영어. 한글은 사람이 읽는 곳(`aliases`, 본문)에만.
- **재컴파일 시 파일명 고정.** 같은 raw 파일이 변경되면 기존 source 파일명을 재사용한다 (로그에서 `raw/파일 → source명` 매핑을 먼저 찾음). 매번 새 이름을 지으면 중복 source가 생기므로.
- **불변 조건:** `[[link]]`가 하나라도 깨져 있으면 컴파일 미완료로 판정.

상세 절차는 `.claude/skills/compile/SKILL.md` 참조.

### 2. `/query` — wiki/에서 답하기

질문을 받으면 `wiki/index.md`부터 시작해 관련 페이지를 재귀로 따라가며 답을 구성한다. 벡터 검색 없이.

**핵심 특징:**

- **Frontier / Visited 탐색 루프.** 초기 후보 → 링크 추출 → 새 후보 → ... 를 depth 2까지 (최대 15 페이지). 종료 조건(Frontier 비움 또는 depth=2)을 **답변 상단의 `<details>` 탐색 로그에 명시적으로 선언**해야 한다. 사용자가 펼치면 재귀가 실제로 돌았는지 검증 가능.
- **과포함 + 가시적 배제.** 의심스러우면 일단 후보에 넣는다. 경계 페이지(반박·정정·리뷰)를 놓치는 게 가장 치명적이라. 배제는 한 줄 근거와 함께 로그에 남긴다.
- **Grep 안전망.** Round 1 끝에 핵심 키워드로 `wiki/` 전체를 한 번 Grep. 인덱스 설명이 약하거나 링크 그래프에서 고립된 `critic-review-*` 같은 페이지를 여기서 건진다.
- **근거 표시는 bullet/단락 단위.** 각 bullet 끝에 `— [[p1]], [[p2]]`. 추론 bullet은 `LLM 추론:` 접두어로 시작. 문장 단위 인라인 태그는 한국어 긴 문장에서 꼬리가 무거워 포기. 섹션 단위는 사실/추론 경계가 흐려져 포기. bullet/단락이 균형점.
- **TL;DR 필수.** 본문 앞에 한 문장 요약 + 2~3 bullet. **독자가 여기서 멈춰도 80%가 답변**되어야 한다. 약어(`R_ct(전하이동 저항)`)는 첫 등장 시 풀이. kebab-case 슬러그(`critic-review-*`)는 본문에 노출하지 않고 근거 라인에만.
- **모순은 대비표로.** 양쪽 bullet 수 ±1 이내. 한쪽이 약해도 "근거 없음"이라고 쓸지언정 비우지 않는다.
- **Synthesis 자동 승격.** Visited에 2개 이상 source가 있고 관점이 다르면 synthesis 플래그 ON. 답변 본문을 이미 synthesis 형식으로 작성해 두고, 사용자에게 저장 여부만 묻는다. 답변을 다시 쓰는 이중 작업이 없다.

상세 절차는 `.claude/skills/query/SKILL.md` 참조.

### 3. `/graph-lint` — 그래프 품질 점검

주기적으로 wiki/의 구조적 결함을 찾아 고친다. **자동 수정 vs 사용자 판단** 이분법으로 동작.

**자동 수정 (묻지 않음):**

- 깨진 concept 링크 → 스텁 파일 즉시 생성. (compile 누락에서 오는 구조적 결함이라 보고만 하고 끝내지 않는다.)
- 중복 concept 병합 → aliases 통합 + 본문 병합 + 링크 일괄 교체.
- frontmatter 필드 누락 복구.
- `wiki/index.md` 동기화 — 유령 엔트리 제거, 누락 엔트리 추가.

**사용자 판단 요청:**

- 고아 concept (아무도 안 쓰는 개념) 삭제 여부.
- 원본 없는 source (raw 파일이 사라진 경우) 처리.
- 오타로 의심되는 링크 리네이밍 여부.

**스캔 순서가 결과에 영향을 준다.** 스텁 생성 먼저, 고아 탐지 나중 — 아니면 방금 만든 스텁이 "고아"로 잡혀 버린다. 깨진 링크가 0개가 아니면 graph-lint는 완료로 판정하지 않는다.

상세 절차는 `.claude/skills/graph-lint/SKILL.md` 참조.

## 입력 규칙

- `raw/`에는 마크다운/텍스트만 넣는다.
- 이미지/첨부파일은 `raw/assets/`에 넣는다 (Obsidian의 attachment folder).
- 비텍스트 파일은 변환 후 넣는다:

| 소스 | 추천 도구 |
|---|---|
| PDF | [marker](https://github.com/VikParuchuri/marker) |
| YouTube | [yt-dlp](https://github.com/yt-dlp/yt-dlp) 자막 추출 |
| 음성 | [whisper](https://github.com/openai/whisper) |
| 웹 기사 | [Obsidian Web Clipper](https://obsidian.md/clipper), [Jina Reader](https://r.jina.ai) |

## Obsidian 설정 (선택)

wiki를 Obsidian으로 열면 그래프 뷰에서 지식 구조를 시각적으로 탐색할 수 있다. Karpathy의 비유로 하면 **Obsidian은 IDE, wiki는 소스코드, LLM은 프로그래머**다.

**그래프 뷰 색상 그룹** (Settings → Graph → Groups):

| Query | 색상 |
|---|---|
| `path:wiki/sources` | 파란색 |
| `path:wiki/concepts` | 주황색 |
| `path:wiki/syntheses` | 초록색 |

**권장 설정:**
- Arrows: 켜기
- Orphans: 끄기
- Search 필터: `-path:raw`
- Attachment folder path: `raw/assets/`

## 다른 RAG 방식과의 비교

| 관점 | Naive RAG | Graph RAG | Vault (Karpathy-style) |
|---|---|---|---|
| 핵심 방식 | 질문마다 벡터 검색 | 엔티티/관계 그래프 탐색 | 미리 컴파일된 위키에서 읽기 |
| 지식 축적 | 없음 | 그래프 자체가 축적 | 답변도 synthesis로 축적 |
| 사람이 읽을 수 있나 | 아니오 (벡터 DB) | 아니오 (트리플) | 예 (Obsidian 마크다운) |
| 인프라 | 벡터 DB 서버 | 그래프 DB 서버 | 없음 (파일만) |
| 유지비 | 재인덱싱 | 스키마 관리 | LLM이 `/graph-lint`로 자가 관리 |

## 호환 환경

이 시스템은 Claude Code뿐 아니라 `CLAUDE.md`와 스킬 파일을 읽을 수 있는 모든 LLM 코딩 에이전트에서 작동한다 (Cline, Cursor 등).

### Cline에서 사용하기

Cline은 `CLAUDE.md` 대신 `.clinerules/` 폴더를 프로젝트 규칙으로 인식한다.

```bash
# 프로젝트 루트에서
mkdir -p .clinerules
cp CLAUDE.md .clinerules/vault-schema.md
```

이후 Cline이 `.clinerules/vault-schema.md`를 자동으로 읽고 동일한 규칙을 따른다.

## License

MIT
