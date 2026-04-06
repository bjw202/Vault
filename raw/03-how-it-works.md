# AI Agency 동작 방식: 실제 사용 시나리오

## 실행 방법

Claude Code 안에서 `/agency` 명령어로 실행한다:

```bash
# 전체 파이프라인 실행 (기획 → 카피 → 디자인 → 빌드 → 평가 → 학습)
/agency brief

# 개별 단계 실행
/agency build    # Builder + Evaluator (GAN Loop)
/agency review   # Evaluator만 실행
/agency learn    # Learner만 실행
/agency evolve   # 학습된 패턴을 에이전트에 적용
/agency resume   # 중단된 파이프라인 재개
/agency profile  # 사용자 프로필 확인
```

---

## 시나리오: SaaS 랜딩페이지 제작

### Step 1: 사용자가 요청한다

```
사용자: "/agency brief"
또는
사용자: "우리 AI 코드 리뷰 도구 랜딩페이지 만들어줘"
```

### Step 2: Planner가 인터뷰한다

Planner(Opus)가 구조화된 질문을 던진다:

```
Planner: "프로젝트의 비즈니스 목표가 무엇인가요?"
사용자: "신규 사용자 가입 유도. 월 100명 목표."

Planner: "주요 타겟 고객은 누구인가요?"
사용자: "중소기업 개발팀 리드. 30-45세."

Planner: "선호하는 톤이 있으세요?"
사용자: "전문적이면서도 친근하게. 너무 딱딱하지 않게."

Planner: "레퍼런스 사이트가 있으면 알려주세요."
사용자: "linear.app 느낌이 좋아요."

Planner: "기술 스택 선호가 있나요?"
사용자: "Next.js + Vercel."
```

**결과물:** `BRIEF-20260405-001.md` 생성 + `.agency/context/` 파일 업데이트

### Step 3: Copywriter와 Designer가 동시에 작업한다

**Copywriter 출력 (JSON):**
```json
{
  "hero": {
    "headline": "코드 리뷰, 12분이면 충분합니다",
    "subheadline": "AI가 보안 취약점과 성능 이슈를 자동으로 잡아냅니다. 2,400개 팀이 이미 사용 중.",
    "cta_text": "무료로 시작하기"
  },
  "problem": {
    "headline": "PR 리뷰에 하루 47분을 쓰고 계신가요?",
    "body": "평균 개발팀은 코드 리뷰에 전체 업무 시간의 15%를 사용합니다..."
  }
}
```

**Designer 출력 (design-spec.md):**
```
Color Tokens:
  --primary: #2563EB (linear.app 레퍼런스 기반)
  --primary-light: #60A5FA
  --bg: #0F172A (다크 모드 기본)
  --text: #F1F5F9

Typography:
  Heading: Inter, 600weight
  Body: Inter, 400weight, 1.6 line-height

Layout:
  Max-width: 1280px
  Grid: 12-column
  Section spacing: 120px
```

### Step 4: Builder가 코드를 작성한다

Builder(Sonnet)가 Copywriter의 JSON과 Designer의 spec을 받아서:

```
src/
├── app/
│   ├── layout.tsx          ← 글로벌 레이아웃 + 폰트 설정
│   └── page.tsx            ← 섹션 컴포넌트 조합
├── components/
│   ├── hero.tsx            ← "코드 리뷰, 12분이면 충분합니다" (텍스트 변경 금지)
│   ├── problem.tsx         ← "PR 리뷰에 하루 47분을..."
│   ├── features.tsx
│   ├── pricing.tsx
│   └── cta.tsx
└── styles/
    └── tokens.css          ← --primary: #2563EB 등 디자인 토큰
```

### Step 5: Evaluator가 평가한다

```
== Evaluation Report ==

Desktop Screenshot (1280x720): ✅
Mobile Screenshot (375x667): ✅

Must-Pass Criteria:
  [✅] Brand Consistency      - 색상/타이포 brand context 일치
  [✅] Responsive Design       - 모바일 정상
  [✅] Core Content Present    - 5/5 섹션 구현
  [✅] CTA Functionality       - 클릭 반응 정상
  [❌] No Broken Elements      - hero 배경 이미지 404
  [✅] Accessibility Baseline  - Lighthouse 93점

Nice-to-Have:
  Animation Quality:  0.65 / 1.0
  Copy Excellence:    0.90 / 1.0
  Performance:        0.85 / 1.0
  Code Quality:       0.80 / 1.0

Overall Score: 0.68 → FAIL (기준: 0.75)
Key Feedback: hero 배경 이미지 경로 수정 필요, 스크롤 애니메이션 개선
```

### Step 6: GAN Loop - Builder가 수정한다

```
Iteration 2:
  - hero 배경 이미지 경로 수정
  - 스크롤 애니메이션 Framer Motion으로 교체
  
Evaluator 재평가: 0.81 → PASS!
```

### Step 7: Learner가 학습한다

```
Learning Entry:
  id: LEARN-20260405-001
  category: layout
  observation: "hero 섹션에서 배경 이미지 경로 누락이 반복됨"
  count: 1
  confidence: 0.0
  status: observation
```

이 패턴이 5번 반복되면, Builder의 EVOLVABLE Zone에 "hero 배경 이미지 존재 여부 사전 검증" 규칙이 추가될 수 있다.

---

## 에이전트 간 데이터 흐름 요약

```
.agency/context/brand-voice.md ──────────────────────┐
.agency/context/visual-identity.md ──────────────────┤
.agency/context/target-audience.md ──────────────────┤
.agency/context/tech-preferences.md ─────────────────┤
.agency/context/quality-standards.md ────────────────┤
                                                      ▼
사용자 요청 ──→ [Planner] ──→ BRIEF-XXX.md
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼               │
              [Copywriter]   [Designer]            │
                    │              │               │
                    ▼              ▼               │
                copy.json   design-spec.md         │
                    │              │               │
                    └──────┬───────┘               │
                           ▼                       │
                      [Builder] ──→ src/           │
                           │                       │
                           ▼                       │
                     [Evaluator] ←─────────────────┘
                           │            (BRIEF 기준으로 평가)
                      PASS/FAIL
                           │
                           ▼
                      [Learner] ──→ .agency/learnings/
```

---

## 에이전트 모델 배정과 그 이유

| 에이전트 | 모델 | 이유 |
|---------|------|------|
| Planner | **Opus** | 인터뷰 설계, 요구사항 분석에 높은 추론력 필요 |
| Copywriter | Sonnet | 텍스트 생성은 Sonnet으로 충분, 비용 효율 |
| Designer | Sonnet | 디자인 시스템 설계도 Sonnet 수준이면 적절 |
| Builder | Sonnet | 코드 생성의 주력, Sonnet이 비용 대비 최적 |
| Evaluator | Sonnet | 읽기 전용(plan 모드), 판단력은 Sonnet 충분 |
| Learner | **Opus** | 패턴 감지, 모순 확인, 진화 설계에 고급 추론 필요 |

**비용 최적화**: 가장 많이 반복되는 Builder + Evaluator(GAN Loop)는 Sonnet으로, 한 번만 실행되는 Planner와 Learner는 Opus로 배정.

---

## 에이전트별 Permission Mode

| 에이전트 | permissionMode | 의미 |
|---------|---------------|------|
| Planner | `default` | 표준 권한 확인 (파일 쓰기 시 사용자 승인) |
| Copywriter | `acceptEdits` | 파일 편집 자동 승인 (카피 작성에 집중) |
| Designer | `acceptEdits` | 파일 편집 자동 승인 |
| Builder | `acceptEdits` | 파일 편집 자동 승인 (코드 작성에 집중) |
| Evaluator | **`plan`** | **읽기 전용** — 코드 수정 불가 |
| Learner | `acceptEdits` | 스킬/에이전트 파일 수정 필요 |

**설계 의도**: Evaluator가 읽기 전용인 이유는 **독립적 판단**을 보장하기 위함이다. 평가자가 코드를 직접 수정할 수 있으면 "고치면 되니까 PASS"라는 유혹에 빠질 수 있다.

---

## 안전장치 (5-Layer Safety)

### Layer 1: Frozen Guard — "이것만은 절대 바꿀 수 없다"

각 에이전트 정의에는 `FROZEN ZONE`이 있다:
```markdown
## FROZEN ZONE
### Identity       ← 에이전트가 누구인지 (변경 불가)
### Safety Rails   ← 안전 규칙 (변경 불가)
### Ethical Boundaries ← 윤리 경계 (변경 불가)

## EVOLVABLE ZONE  ← Learner가 수정 가능한 영역
### Style Guidelines
### Output Patterns
```

### Layer 2: Canary Check — "바꾸기 전에 시뮬레이션"

진화 적용 전에 지난 3개 프로젝트에 대해 시뮬레이션을 돌린다.
점수가 0.10 이상 떨어지면 진화를 차단한다.

### Layer 3: Contradiction Detector — "기존 규칙과 모순되면 경고"

새 학습이 기존 규칙과 충돌하면, 양쪽 규칙을 사용자에게 보여주고 선택하게 한다.
절대 기존 규칙을 자동으로 덮어쓰지 않는다.

### Layer 4: Rate Limiter — "너무 빨리 바뀌면 안 된다"

- 주당 최대 3번 진화
- 진화 간 최소 24시간 간격
- 활성 학습 최대 50개 (초과 시 오래된 것 아카이브)

### Layer 5: Human Approval — "사람이 최종 결정"

```
Learner: "Builder에 이 규칙을 추가할까요?"

  Before: (기존 EVOLVABLE Zone)
  After:  (수정된 EVOLVABLE Zone)

  근거: 최근 5개 프로젝트 중 4개에서 같은 패턴 관찰
  신뢰도: 0.85

  [승인] / [거부] / [보류]
```
