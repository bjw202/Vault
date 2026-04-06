# AI Agency 아키텍처 상세

## 파이프라인 구조

AI Agency의 핵심은 **6단계 파이프라인**이다. 각 단계가 순서대로 실행되며, 앞 단계의 출력물이 다음 단계의 입력이 된다.

```
사용자 요청: "SaaS 제품 랜딩페이지 만들어줘"
    │
    ▼
┌──────────┐
│ Planner  │  "무엇을 만들 것인가?" → BRIEF 문서 출력
│ (Opus)   │
└────┬─────┘
     │ BRIEF 문서
     ├──────────────────────┐
     ▼                      ▼
┌──────────┐         ┌──────────┐
│Copywriter│         │ Designer │  ← 이 둘은 병렬 실행
│ (Sonnet) │         │ (Sonnet) │
└────┬─────┘         └────┬─────┘
     │ 카피 JSON           │ 디자인 스펙
     └──────────┬──────────┘
                ▼
         ┌──────────┐
    ┌───→│ Builder  │  카피 + 디자인 → 코드
    │    │ (Sonnet) │
    │    └────┬─────┘
    │         │ 빌드된 코드
    │    ┌────┴─────┐
    │    │Evaluator │  Playwright 테스트 + 4차원 점수
    │    │ (Sonnet) │
    │    └────┬─────┘
    │         │
    │   FAIL?─┤──PASS?
    │         │       │
    └─────────┘       ▼
    GAN Loop     ┌──────────┐
    (최대 5회)    │ Learner  │  피드백 수집 → 진화 제안
                 │ (Opus)   │
                 └──────────┘
```

---

## 파이프라인 라우팅: 누가, 어떻게 제어하는가

파이프라인에서 가장 중요한 질문은 **"누가 다음 에이전트를 호출하는가?"** 이다.

### 라우팅의 주체: MoAI 오케스트레이터

별도의 "라우터 에이전트"는 없다. **MoAI 메인 세션 자체가 라우터**이다.
그 동작은 `.claude/skills/agency/SKILL.md`에 선언적으로 정의되어 있다.

```
사용자 → "/agency build" 또는 "랜딩페이지 만들어줘"
            │
            ▼
      ┌───────────┐
      │   MoAI    │  ← 메인 세션 (오케스트레이터)
      │           │
      │ 1. Skill("agency") 로드
      │ 2. SKILL.md의 지시를 읽는다
      │ 3. 순서대로 Agent() 호출
      └───────────┘
            │
            ├── Agent(subagent_type="planner")    → BRIEF.md 반환
            ├── Agent(subagent_type="copywriter") → copy.json 반환
            ├── Agent(subagent_type="designer")   → design-spec.md 반환
            ├── Agent(subagent_type="builder")    → 코드 반환
            ├── Agent(subagent_type="evaluator")  → PASS/FAIL 반환
            │       │
            │       └── FAIL → builder 재호출 (GAN Loop)
            │       └── PASS → 다음 단계
            └── Agent(subagent_type="learner")    → 학습 결과 반환
```

### 라우팅의 3계층

**Level 1: 서브커맨드 라우팅** — 사용자 명령을 해석

```
"/agency build"   → 전체 파이프라인 실행
"/agency brief"   → Planner만 실행
"/agency review"  → Evaluator만 실행
"/agency learn"   → Learner만 실행
"/agency evolve"  → Learner(진화 모드) 실행
자연어 입력       → brief → build 자동 연결 ("Just do it")
```

**Level 2: 파이프라인 순서 제어** — 에이전트 호출 순서

SKILL.md의 Step 4가 이 로직을 정의한다:

```
1. BRIEF 존재 확인 → 없으면 Agent(planner) 호출
2. Agent(copywriter)  → copy.md 생성
3. Agent(designer)    → design-spec.md 생성
   (--team 플래그 시 2, 3을 병렬로 동시 실행)
4. Agent(builder)     → 코드 생성
5. Agent(evaluator)   → PASS/FAIL 판정
6. FAIL이면 → 4번으로 돌아감 (최대 5회)
7. PASS이면 → Agent(learner) 호출
```

**Level 3: 조건부 라우팅** — 분기 판단

```
┌─ 사전 조건: brand-voice.md 값이 "_TBD_"인가?
│   → YES: Planner에게 인터뷰 먼저 실행
│   → NO: 바로 파이프라인 진행
│
├─ GAN Loop: evaluator 결과 점수 확인
│   → score ≥ 0.75:  PASS → learner로 진행
│   → score < 0.75:  FAIL → builder 재호출 (피드백 포함)
│   → iteration ≥ 5: 사용자에게 AskUserQuestion
│   → 개선 < 0.05 × 2연속: 정체 알림
│
└─ 에스컬레이션: 3회 연속 FAIL 시 사용자에게 개입 요청
```

### 데이터 전달 방식: 파일 기반 간접 통신

에이전트들은 **서로 직접 통신하지 않는다**. MoAI가 중개한다:

```
Planner ──→ BRIEF.md (파일로 저장)
                ↑
MoAI가 읽어서 ──→ Copywriter 프롬프트에 BRIEF 내용 포함
MoAI가 읽어서 ──→ Designer 프롬프트에 BRIEF 내용 포함
                        ↓
Copywriter ──→ copy.json (파일로 저장)
Designer   ──→ design-spec.md (파일로 저장)
                        ↑
MoAI가 두 파일을 읽어서 ──→ Builder 프롬프트에 포함
```

**이것은 Stock Research 하네스의 P2P SendMessage 방식과 대비된다:**

| 방식 | Agency (현재) | Stock Research |
|------|-------------|----------------|
| 통신 | 파일 기반 간접 (MoAI 중개) | P2P SendMessage 직접 |
| 제어 | MoAI가 순차 호출 | Agent Teams + 자율 협업 |
| 장점 | 단순, 예측 가능, 디버깅 쉬움 | 실시간 교차 검증, 시너지 |
| 단점 | 실시간 협업 불가 | 복잡, 메시지 관리 필요 |

### SKILL.md = 선언적 파이프라인 스크립트

핵심 통찰: **SKILL.md 파일이 사실상 파이프라인의 "코드"**이다.

에이전트 정의(`.claude/agents/agency/*.md`)는 **"누구인가"** 를 정의하고,
스킬 정의(`.claude/skills/agency/SKILL.md`)는 **"어떤 순서로, 어떤 조건으로 실행하는가"** 를 정의한다.

나만의 에이전시를 만들 때 이 구분이 핵심이다:
- 에이전트 = 직원 (역할, 전문성, 도구, 권한)
- 스킬(SKILL.md) = 업무 매뉴얼 (워크플로우, 순서, 조건, 분기)

---

## 각 단계의 입출력 관계

### Phase 1: Planner (기획)

```
입력: 사용자 요청 (자연어) + .agency/context/ (브랜드 컨텍스트)
출력: .agency/briefs/BRIEF-YYYYMMDD-NNN.md
```

**하는 일:**
1. 사용자에게 구조화된 인터뷰를 진행 (비즈니스 목표 → 타겟 → 브랜드 → 기술 요구)
2. `.agency/context/`에 이미 있는 정보는 물어보지 않음 (중복 방지)
3. 수집한 내용을 7개 섹션의 BRIEF 문서로 정리
4. 첫 실행 시 `.agency/context/` 파일들도 채워줌

**BRIEF 문서 구조:**
```
1. Metadata       - ID, 상태, 타입, 프레임워크
2. Project Goal   - 비즈니스 목표, KPI
3. Target Audience - 페르소나, 고객 여정
4. Brand and Tone  - 브랜드 보이스, 색상, 타이포
5. Content         - 페이지/섹션 목록, 핵심 메시지, CTA
6. Tech Constraints - 플랫폼, 프레임워크, 통합 서비스
7. Deliverables    - 기대 산출물 체크리스트
8. Evaluation      - Must-Pass 6개 + Nice-to-Have 7개 평가 기준
```

### Phase 2a: Copywriter (카피 작성)

```
입력: BRIEF 문서 + .agency/context/brand-voice.md
출력: 섹션별 JSON 구조 카피
```

**하는 일:**
1. BRIEF의 각 페이지/섹션에 대해 카피 작성
2. 출력 형식은 JSON:
   ```json
   {
     "hero": {
       "headline": "Build Better Products, 3x Faster",
       "subheadline": "Join 2,400+ teams shipping quality code",
       "body": "MoAI automates the boring parts...",
       "cta_text": "Start Free Trial"
     },
     "features": { ... },
     "pricing": { ... }
   }
   ```
3. AI 슬롭 표현 금지 ("innovative solutions" 같은 진부한 문구)
4. 구체적 숫자 사용 ("+30% 생산성" 대신 "PR 리뷰 시간 47분 → 12분")

### Phase 2b: Designer (디자인 설계) — Copywriter와 동시 실행

```
입력: BRIEF 문서 + .agency/context/visual-identity.md
출력: design-spec.md (디자인 시스템 + 컴포넌트 스펙)
```

**하는 일:**
1. **Hero 섹션을 먼저 디자인** — 이것이 전체 사이트의 톤을 결정
2. Hero에서 확립된 디자인 언어로 나머지 섹션을 체이닝
3. 출력물:
   - **컬러 토큰**: `--color-primary: #2563EB` 형태
   - **타이포 스케일**: 각 헤딩/본문의 폰트, 크기, 무게
   - **스페이싱 시스템**: 4px 기반 간격 체계
   - **컴포넌트 스펙**: 버튼, 카드, 네비게이션 등의 설계
   - **반응형 그리드**: 모바일/태블릿/데스크톱 브레이크포인트

### Phase 3: Builder (코드 구현)

```
입력: 카피 JSON + design-spec.md
출력: 실제 동작하는 코드 (Next.js + Tailwind + shadcn/ui)
```

**하는 일:**
1. 디자인 토큰을 Tailwind config/CSS 변수로 변환
2. 카피 JSON의 텍스트를 **그대로** 사용 (수정 절대 금지)
3. 컴포넌트 단위로 구현 (hero, features, pricing 등)
4. 반응형 구현 (mobile-first)
5. TDD 방식으로 테스트 작성

**절대 규칙:**
- 카피라이터가 쓴 텍스트 한 글자도 바꾸지 않는다
- 디자인 토큰 외 임의 색상/크기 사용 금지
- 시맨틱 HTML + ARIA 접근성 필수

### Phase 4: Evaluator (품질 평가)

```
입력: 빌드된 코드 + BRIEF 문서
출력: evaluation-report.md (PASS/FAIL + 점수 + 결함 목록)
```

**하는 일:**
1. Playwright로 데스크톱(1280x720) + 모바일(375x667) 스크린샷
2. 모든 버튼, 링크, CTA 클릭 테스트
3. Lighthouse 감사 실행
4. 4차원 품질 점수 산출:

| 차원 | 가중치 | 평가 내용 |
|------|--------|----------|
| Design Quality | 30% | 디자인 스펙 준수, 시각적 일관성 |
| Originality | 25% | AI 슬롭이 아닌 독창적 디자인인가 |
| Completeness | 25% | BRIEF의 모든 섹션이 구현되었는가 |
| Functionality | 20% | 인터랙션, 반응형, 에러 없음 |

**무조건 FAIL 조건 (Hard Fail):**
- 카피가 원본과 다름
- AI 슬롭 패턴 감지 (보라색 그라디언트 + 흰색 카드 + 제네릭 아이콘)
- 모바일에서 깨짐
- 404 링크 존재

### Phase 5: Learner (학습 및 진화)

```
입력: evaluation-report.md + 세션 히스토리
출력: 학습 엔트리 + (선택적) 에이전트/스킬 수정 제안
```

**하는 일:**
1. 평가 결과에서 패턴 감지 (예: "매번 모바일 네비게이션에서 감점")
2. 관찰 횟수에 따라 분류:
   - 1회 → 관찰 (기록만)
   - 3회 → 휴리스틱 (제안에 반영)
   - 5회 → 규칙 (승격 후보)
   - 10회+ → 고신뢰 (자동 제안)
3. 규칙 승격 시: 해당 에이전트의 **EVOLVABLE Zone**만 수정 제안
4. 사용자 승인 후 적용 → 다음 프로젝트부터 반영

---

## GAN Loop 상세

GAN Loop는 **Generative Adversarial Network**에서 영감을 받은 구조이다:
- **Generator** = Builder (코드 생성)
- **Discriminator** = Evaluator (품질 판별)

```
Builder가 코드를 생성 (Iteration 1)
    ↓
Evaluator가 점수를 매김 → 0.62 (FAIL, 기준 0.75)
    ↓ 피드백: "모바일 네비게이션 깨짐, CTA 색상 불일치"
    ↓
Builder가 피드백 반영 (Iteration 2)
    ↓
Evaluator가 점수를 매김 → 0.71 (FAIL)
    ↓ 피드백: "CTA 수정됨, 하지만 스크롤 애니메이션 끊김"
    ↓
Builder가 피드백 반영 (Iteration 3)
    ↓
Evaluator가 점수를 매김 → 0.78 (PASS!)
    ↓
Learner로 진행
```

**탈출 조건:**
- 점수 ≥ 0.75 → PASS → Learner로 진행
- 5회 반복 도달 → 실패 보고서 → 사용자에게 3가지 선택지 제시
  - (A) 기준 낮추기
  - (B) 가이드 제공 후 재시도
  - (C) 강제 통과

**정체 감지:**
- 연속 2회 점수 개선이 0.05 미만이면 정체로 판단
- Evaluator가 **다른 차원**에서 개선점을 찾아야 함

---

## 파일 시스템 구조

```
프로젝트/
├── .claude/
│   └── agents/
│       └── agency/           ← 6개 에이전트 정의
│           ├── planner.md
│           ├── copywriter.md
│           ├── designer.md
│           ├── builder.md
│           ├── evaluator.md
│           └── learner.md
│
├── .claude/skills/
│   ├── agency-client-interview/  ← Planner 스킬
│   ├── agency-copywriting/       ← Copywriter 스킬
│   ├── agency-design-system/     ← Designer/Builder 스킬
│   ├── agency-evaluation-criteria/ ← Evaluator 스킬
│   └── agency-frontend-patterns/ ← Builder 스킬
│
├── .claude/rules/
│   └── agency/
│       └── constitution.md   ← Agency 헌법 (변경 불가 규칙)
│
└── .agency/                  ← Agency 데이터
    ├── config.yaml           ← 파이프라인 설정
    ├── fork-manifest.yaml    ← MoAI 포크 추적
    ├── context/              ← 브랜드 컨텍스트 (사용자만 수정)
    │   ├── brand-voice.md
    │   ├── visual-identity.md
    │   ├── target-audience.md
    │   ├── tech-preferences.md
    │   └── quality-standards.md
    ├── templates/
    │   └── brief-template.md ← BRIEF 문서 템플릿
    ├── briefs/               ← 생성된 BRIEF 문서들
    ├── learnings/            ← 학습된 패턴들
    └── evolution/            ← 진화 이력
```

---

## 브랜드 컨텍스트: 일관성의 비결

`.agency/context/` 폴더의 5개 파일이 모든 에이전트의 행동을 규정한다:

| 파일 | 역할 | 사용하는 에이전트 |
|------|------|----------------|
| `brand-voice.md` | 톤, 어투, 감정, 금기 표현 | Copywriter, Planner |
| `visual-identity.md` | 색상, 타이포, 아이콘, 레이아웃 | Designer, Builder |
| `target-audience.md` | 페르소나, 고객 여정, 의사결정 요인 | Planner, Copywriter |
| `tech-preferences.md` | 프레임워크, 라이브러리, 호스팅 | Builder |
| `quality-standards.md` | 성능 기준, 접근성, SEO, 테스트 | Evaluator, Builder |

**핵심 규칙:**
- 이 파일들은 **Learner도 수정할 수 없다** (사용자만 수정 가능)
- 첫 `/agency brief` 실행 시 인터뷰를 통해 채워진다
- 한번 설정하면 이후 모든 프로젝트에 일관되게 적용된다

---

## 설정 파일 해설: config.yaml

```yaml
agency:
  # GAN Loop 설정
  gan_loop:
    max_iterations: 5        # 최대 반복 횟수
    pass_threshold: 0.75     # 이 점수 이상이면 PASS
    escalation_after: 3      # 3회 실패 시 사용자에게 알림
    improvement_threshold: 0.05  # 이 이하 개선은 "정체"로 판단

  # 자기진화 설정
  evolution:
    require_approval: true   # 사용자 승인 필수
    max_evolution_rate_per_week: 3  # 주당 최대 3번 진화
    cooldown_hours: 24       # 진화 간 최소 24시간 간격
    graduation_criteria:
      minimum_observations: 5    # 최소 5번 관찰되어야 규칙 후보
      minimum_confidence: 0.80   # 신뢰도 80% 이상
```

이 설정은 사용자가 자유롭게 조정할 수 있다. 예를 들어:
- `pass_threshold: 0.60` → 느슨한 품질 기준 (프로토타입용)
- `max_iterations: 3` → 더 빠른 반복 (속도 우선)
- `require_approval: false` → 자동 진화 (신뢰 높을 때)
