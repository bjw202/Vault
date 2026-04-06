# AI Agency 자기진화 시스템 상세

## 자기진화란?

AI Agency는 프로젝트를 반복할수록 **스스로 더 나아지는** 시스템이다.
사람이 직접 에이전트를 수정하지 않아도, Learner가 패턴을 감지하고 개선을 제안한다.

```
프로젝트 1: Builder가 모바일 네비게이션 구현을 자주 틀림 → Learner가 관찰 기록
프로젝트 2: 같은 실수 반복 → 2회 관찰
프로젝트 3: 또 반복 → 3회 → "휴리스틱"으로 승격
프로젝트 4: 또 반복 → 4회
프로젝트 5: 또 반복 → 5회 → "규칙 후보"로 승격
    ↓
Learner가 Builder의 EVOLVABLE Zone에 규칙 추가를 제안
    ↓
사용자 승인
    ↓
프로젝트 6부터: Builder가 모바일 네비게이션 체크를 자동으로 수행
```

---

## 학습 파이프라인 단계별

### Stage 1: 관찰 (Observation)

Evaluator의 피드백에서 패턴을 감지한다:

```yaml
id: LEARN-20260405-001
category: layout
observation: "모바일 뷰포트에서 네비게이션 메뉴가 겹침"
evidence:
  - project_id: BRIEF-20260320-001
    score_before: 0.62
    score_after: 0.78
    context: "Builder가 mobile breakpoint에서 hamburger 메뉴 구현 누락"
count: 1
confidence: 0.0
status: observation
```

### Stage 2: 반복 관찰 → 신뢰도 상승

같은 패턴이 다른 프로젝트에서 발견될 때마다:
- count 증가
- confidence 재계산

```
1회: observation (기록만)
3회: heuristic (제안에 반영 시작)
5회: rule (승격 후보, 신뢰도 0.80 이상 시)
10회+: high-confidence (자동 제안)
```

### Stage 3: 졸업 심사 (Graduation)

5회 이상 관찰 + 신뢰도 0.80 이상이면 졸업 심사에 들어간다:

**졸업 조건 (모두 충족해야 함):**
1. `minimum_observations: 5` — 최소 5번 관찰
2. `minimum_confidence: 0.80` — 신뢰도 80% 이상
3. `consistency_ratio: 0.80` — 최근 5회 중 4회 일관적
4. 기존 규칙과 모순 없음
5. 30일 이내 관찰 (staleness 체크)

### Stage 4: 진화 제안 생성

졸업 심사 통과 시, Learner가 구체적인 수정 제안을 만든다:

```
타겟: .claude/agents/agency/builder.md
섹션: EVOLVABLE ZONE > Code Patterns

Before:
  ### Code Patterns
  - Component-first architecture
  - Responsive mobile-first implementation
  - Performance budget: Lighthouse >= 80

After:
  ### Code Patterns
  - Component-first architecture
  - Responsive mobile-first implementation
  - Performance budget: Lighthouse >= 80
  - Mobile navigation: always implement hamburger menu for < 768px breakpoint
  - Verify navigation rendering at 375px before moving to other components

근거: 5개 프로젝트 중 5개에서 모바일 네비게이션 결함 발견
신뢰도: 0.87
```

### Stage 5: 안전 검증 → 사용자 승인 → 적용

```
Canary Check: 지난 3개 프로젝트에 적용 시뮬레이션 → 점수 하락 없음 ✅
Contradiction Check: 기존 규칙과 모순 없음 ✅
Rate Limit: 이번 주 진화 1/3 → 가능 ✅
    ↓
사용자에게 diff 프리뷰 제시 → 승인 ✅
    ↓
builder.md EVOLVABLE Zone 수정
generation: 0 → 1 (fork-manifest.yaml 업데이트)
evolution-log.md에 기록
학습 엔트리 → "graduated" 상태로 변경 → archive/로 이동
```

---

## 신뢰도 감쇄 (Confidence Decay)

학습된 패턴도 시간이 지나면 관련성이 떨어진다. 이를 방지하기 위해 **반감기** 공식을 사용한다:

```
weight = base_confidence × 0.5^(경과일수 / 90)
```

| 경과 기간 | 잔여 신뢰도 (base=1.0) |
|----------|---------------------|
| 0일 | 1.00 |
| 30일 | 0.79 |
| 60일 | 0.63 |
| 90일 | 0.50 (반감기) |
| 180일 | 0.25 |
| 270일 | 0.125 |

**0.30 미만으로 떨어지면 폐기 후보**로 분류된다.

이 메커니즘은 "옛날에는 맞았지만 지금은 틀린" 규칙이 계속 적용되는 것을 방지한다.

---

## Anti-Pattern: 즉시 차단

**1회만 발생해도** 치명적인 경우, 즉시 Anti-Pattern으로 등록된다:

**등록 조건:**
- 점수가 0.20 이상 급락 (예: 0.80 → 0.55)
- Must-Pass 기준 실패

**Anti-Pattern의 특징:**
- **FROZEN** — 한번 등록되면 Learner도 삭제할 수 없다
- 이후 모든 평가에서 사전 체크
- 해당 패턴이 발견되면 관련 차원 점수를 **0.50으로 제한**
- 사람만 해제할 수 있다

**예시:**
```yaml
id: AP-20260405-001
category: design
pattern: "보라색-분홍 그라디언트 + 흰색 카드 + Lucide 아이콘 기본 조합"
reason: "AI 슬롭의 전형적 패턴. 3개 요소 동시 사용 시 무조건 FAIL"
created_at: "2026-04-05"
status: anti-pattern  # FROZEN, 수정 불가
```

---

## FROZEN vs EVOLVABLE 경계

각 에이전트 정의 파일에는 명확한 경계가 있다:

```markdown
# Builder - Agency Code Implementer

## FROZEN ZONE ← Learner가 절대 수정할 수 없는 영역

### Identity
"You are the Agency Builder..."  ← 에이전트 정체성

### Safety Rails
- max_evolution_rate: 3/week
- require_approval_for: [tools_add, tools_remove, model_change]
- rollback_window: 7d

### Ethical Boundaries
- NEVER change copy text from copywriter output
- Follow design system tokens exactly
- Ensure accessibility
- No dark patterns

## EVOLVABLE ZONE ← Learner가 수정을 제안할 수 있는 영역

### Framework Preferences       ← "Next.js 대신 Remix 선호" 같은 변경 가능
### Code Patterns              ← "모바일 우선 체크" 같은 규칙 추가 가능
### File Structure             ← 디렉토리 구조 변경 가능
```

**왜 이렇게 나누는가?**

- FROZEN은 에이전트의 **본질적 역할과 안전**을 보호한다
  - Builder가 갑자기 "카피도 수정할게요"라고 하면 안 된다
  - Evaluator가 "의심되지만 PASS 할게요"라고 하면 안 된다
- EVOLVABLE은 **작업 방식의 개선**을 허용한다
  - "Next.js App Router 패턴을 기본으로" → 학습으로 추가 가능
  - "모바일 네비게이션 항상 확인" → 학습으로 추가 가능

---

## Fork Manifest: 업스트림 추적

Agency 에이전트 중 일부는 MoAI 에이전트에서 포크된 것이다:

```yaml
planner:
  upstream: .claude/agents/moai/manager-spec.md  # MoAI의 SPEC 관리자에서 포크
  version_at_fork: v2.9.0
  current_generation: 0      # 아직 진화 없음
  divergence_score: 0.0      # 원본과 동일

builder:
  upstream: .claude/agents/moai/expert-frontend.md  # MoAI의 프론트엔드 전문가에서 포크
  sync_policy: manual        # 수동 동기화

copywriter:
  upstream: null              # 완전히 새로 만든 에이전트 (원본 없음)
```

**generation이 올라갈수록** 원본과 달라진다:
- generation 0: 원본과 동일
- generation 1-3: 약간 수정됨
- generation 5+: 상당히 달라짐
- divergence_score > 0.80: 사실상 독립적인 에이전트

**MoAI 업데이트 시:**
- `sync_policy: auto-propose` → 자동으로 머지 제안 생성
- `sync_policy: manual` → 사용자에게 변경 사항만 알려줌
- divergence_score > 0.80 → 동기화 무시 (이미 다른 에이전트)

---

## 자기진화의 의미

이 시스템의 핵심 통찰은 다음과 같다:

1. **AI가 자기 자신을 개선하되, 핵심은 변하지 않는다** (FROZEN/EVOLVABLE 경계)
2. **변화는 점진적이다** (주 3회, 24시간 간격, 5회 관찰 필요)
3. **사람이 최종 결정한다** (require_approval: true)
4. **잘못된 변화는 자동 복구된다** (Canary Check + 7일 롤백 윈도우)
5. **오래된 지식은 자연스럽게 사라진다** (90일 반감기)

이것은 단순한 프롬프트 개선이 아니라, **에이전트의 행동 규칙 자체가 진화하는 시스템**이다.
