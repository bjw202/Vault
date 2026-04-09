# Vault

LLM이 유지하는 개인 지식 그래프 시스템. [Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을 구현한다.

자료를 넣으면 LLM이 자동으로 지식 그래프를 만들고 유지한다. 자료가 쌓일수록 위키가 풍부해지고, 답변 품질이 올라간다.

## 설계 철학

| Karpathy 원칙 | Vault 구현 |
|---|---|
| 3 layers (raw / wiki / schema) | `raw/` → `wiki/` → `CLAUDE.md` |
| `index.md` 1개 | `wiki/index.md` |
| `log.md` 1개, append-only | `_compile_log.md` |
| 3 operations (ingest / query / lint) | `/compile`, `/query`, `/graph-lint` |
| Schema는 얇은 계약 | `CLAUDE.md` ~70줄 |

## 구조

```
Vault/
├── raw/                    # 사용자가 넣는 원본 자료
│   └── assets/             # 이미지, 다이어그램
├── wiki/                   # LLM이 관리하는 지식 그래프
│   ├── index.md            # 통합 인덱스
│   ├── sources/            # 원본 1:1 요약
│   ├── concepts/           # 재사용 가능한 개념
│   └── syntheses/          # 통합 분석
├── .claude/skills/         # 실행 절차 (스킬)
│   ├── compile/
│   │   ├── SKILL.md        # raw → wiki 컴파일 절차
│   │   └── scripts/
│   │       ├── detect-changes.sh  # sha256 기반 변경 감지
│   │       └── validate.sh        # 언어 규칙 + frontmatter 검증
│   ├── query/SKILL.md      # 지식 검색
│   ├── graph-lint/SKILL.md # 그래프 품질 점검
│   └── push/SKILL.md       # GitHub 푸시
├── _compile_log.md         # 컴파일 이력 (append-only)
└── CLAUDE.md               # 시스템 규칙 (얇은 schema)
```

## 지식 객체 3가지

| 객체 | 위치 | 역할 | 예시 |
|---|---|---|---|
| **Source** | `wiki/sources/` | 원본 자료의 요약 카드 | `gear-basic-parameters.md` |
| **Concept** | `wiki/concepts/` | 여러 Source에서 반복되는 개념 | `pressure-angle.md` |
| **Synthesis** | `wiki/syntheses/` | 여러 Source를 엮은 통합 분석 | `gear-design-overview.md` |

## 사용법

### 요구 사항

- [Claude Code](https://claude.ai/claude-code) (CLI 또는 데스크톱 앱)
- [Obsidian](https://obsidian.md) (선택 — wiki 탐색/뷰어)

### 시작하기

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
claude  # Claude Code 실행
# 프롬프트에서: 컴파일 해줘
```

### 3대 연산

#### 1. 컴파일 (`/compile`)

`raw/`의 자료를 `wiki/`로 변환한다.

- 신규/변경 파일만 감지 (sha256 기반)
- **concept-first 순서**: 개념 추출 → 인덱스 대조 → 신규 concept 파일 먼저 생성 → source 작성 + 링크 삽입
- 이 순서 덕분에 `[[link]]`가 박히는 시점에 타깃 파일이 이미 존재한다 (broken link 구조적 방지)
- 상세는 `.claude/skills/compile/SKILL.md` 참조

#### 2. 질문 (`/query`)

wiki에서 관련 지식을 수집하여 질문에 답한다.

- `wiki/index.md`에서 관련 페이지 식별 → `[[wiki links]]` 재귀 탐색
- 좋은 답변은 synthesis로 승격 가능
- 상세는 `.claude/skills/query/SKILL.md` 참조

#### 3. 린트 (`/graph-lint`)

wiki 지식 그래프의 품질을 점검하고 수정한다.

- 깨진 링크, 중복 concept, 고아 문서 탐지
- **깨진 concept 링크는 스텁 파일로 자동 생성** (묻지 않음 — compile 누락의 사후 청소)
- 인덱스 동기화, frontmatter 필드 누락 등은 자동 수정
- 삭제 여부 같은 진짜 애매한 판단만 사용자에게 확인

### 입력 규칙

- `raw/`에는 마크다운/텍스트만 넣는다
- 이미지/첨부파일은 `raw/assets/`에 넣는다
- 비텍스트 파일은 변환 후 넣는다:

| 소스 | 추천 도구 |
|---|---|
| PDF | [marker](https://github.com/VikParuchuri/marker) |
| YouTube | [yt-dlp](https://github.com/yt-dlp/yt-dlp) 자막 추출 |
| 음성 | [whisper](https://github.com/openai/whisper) |
| 웹 기사 | [Obsidian Web Clipper](https://obsidian.md/clipper), [Jina Reader](https://r.jina.ai) |

## Obsidian 설정 (선택)

wiki를 Obsidian으로 열면 그래프 뷰에서 지식 구조를 시각적으로 탐색할 수 있다.

**그래프 뷰 색상 그룹** (Settings > Graph > Groups):

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

| 관점 | Naive RAG | Graph RAG | Vault |
|---|---|---|---|
| 핵심 방식 | 질문마다 벡터 검색 | 엔티티/관계 그래프 탐색 | 미리 컴파일된 위키에서 읽기 |
| 지식 축적 | 없음 | 그래프 자체가 축적 | 답변도 synthesis로 축적 |
| 사람이 읽을 수 있나 | 아니오 (벡터DB) | 아니오 (트리플) | 예 (Obsidian) |
| 인프라 | 벡터DB 서버 | 그래프DB 서버 | 없음 (파일만) |

## 호환 환경

이 시스템은 Claude Code뿐 아니라 CLAUDE.md와 스킬 파일을 읽을 수 있는 모든 LLM 코딩 에이전트에서 작동한다 (Cline, Cursor 등).

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
