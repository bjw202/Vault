# 나만의 에이전시 만들기: Claude Code를 조직 구축 도구로 사용하기

## 핵심 관점 전환

Claude Code는 코딩 도구가 아니다. **에이전트를 정의하고, 역할을 부여하고, 워크플로우를 제어하는 조직 구축 플랫폼**이다.

```
일반적 관점:   Claude Code = 코딩 보조 도구
이 문서의 관점: Claude Code = 가상 기업 운영 플랫폼

    사용자 = CEO (전략 결정, 최종 승인)
    SKILL.md = 업무 프로세스/SOP
    에이전트 = 직원 (역할, 전문성, 도구, 권한)
    .context/ = 사규/문화/가이드라인
    config.yaml = 조직 운영 규정
    constitution.md = 정관 (변경 불가 원칙)
    Learner = 조직 학습/역량 개발 부서
```

---

## 에이전시를 구성하는 4개 레이어

어떤 도메인의 에이전시든, 구성 요소는 동일하다:

```
┌─────────────────────────────────────────────────────────┐
│ Layer 4: 진화 시스템                                      │
│ Learner + 학습 파이프라인 + 안전장치                       │
│ "조직이 경험에서 배우고 성장하는 구조"                       │
├─────────────────────────────────────────────────────────┤
│ Layer 3: 품질 게이트                                      │
│ Evaluator + GAN Loop + PASS/FAIL 기준                    │
│ "결과물이 기준에 도달하는지 검증하는 구조"                   │
├─────────────────────────────────────────────────────────┤
│ Layer 2: 실행 파이프라인                                   │
│ SKILL.md (라우팅 로직) + Agent() 호출 순서                  │
│ "누가, 어떤 순서로, 어떤 조건에서 일하는가"                  │
├─────────────────────────────────────────────────────────┤
│ Layer 1: 에이전트 + 컨텍스트                               │
│ 에이전트 정의 + 스킬 + 도메인 컨텍스트                      │
│ "어떤 직원이 있고, 무엇을 알고, 어떤 도구를 쓰는가"          │
└─────────────────────────────────────────────────────────┘
```

---

## Layer 1: 에이전트 정의 — "직원 채용"

### 에이전트 정의 파일의 구조

파일 위치: `.claude/agents/{에이전시명}/{에이전트명}.md`

```yaml
---
name: my-analyst                    # 고유 식별자
description: |
  이 에이전트가 무엇을 하는지 설명.
  MoAI가 이 설명을 보고 어떤 에이전트를 호출할지 결정한다.
tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch
model: sonnet                       # opus / sonnet / haiku
permissionMode: acceptEdits         # 권한 모드
maxTurns: 100                       # 최대 실행 턴
memory: project                     # 크로스 세션 메모리
skills:
  - my-analysis-framework           # 이 에이전트에 주입할 스킬
---

# My Analyst - 역할 설명

## FROZEN ZONE
### Identity
이 에이전트의 본질적 역할. 절대 변경 불가.

### Safety Rails
안전 규칙들.

### Ethical Boundaries
윤리적 경계.

## EVOLVABLE ZONE
### Analysis Approach
분석 방법론. Learner에 의해 개선 가능.

### Output Patterns
출력 형식. 학습을 통해 진화 가능.
```

### 에이전트 설계 시 결정해야 할 7가지

| 결정 사항 | 선택지 | 기준 |
|----------|--------|------|
| **1. 모델** | opus / sonnet / haiku | 추론 복잡도 vs 비용 |
| **2. 권한** | plan(읽기전용) / acceptEdits / default | 이 에이전트가 파일을 수정해야 하는가? |
| **3. 도구** | Read, Write, Bash, WebSearch 등 | 이 에이전트가 무엇을 할 수 있어야 하는가? |
| **4. 스킬** | 도메인 전문 지식 문서 | 이 에이전트가 무엇을 알아야 하는가? |
| **5. 메모리** | project / user / local / 없음 | 세션 간 학습이 필요한가? |
| **6. FROZEN** | 정체성, 안전, 윤리 | 절대 바뀌면 안 되는 것은? |
| **7. EVOLVABLE** | 작업 방식, 선호도, 패턴 | 경험으로 개선할 수 있는 것은? |

### 모델 선택 가이드

```
opus:   판단이 필요한 역할 (기획, 전략, 진화 설계, 최종 통합)
sonnet: 실행이 필요한 역할 (분석, 작성, 구현, 평가)
haiku:  탐색이 필요한 역할 (자료 수집, 검색, 분류)
```

**비용 최적화 원칙:**
- 반복 실행되는 에이전트(GAN Loop 안의 Builder/Evaluator) → sonnet
- 한 번만 실행되는 판단 에이전트(Planner, Learner) → opus
- 대량 병렬 탐색 에이전트(Researcher) → haiku

### 권한(permissionMode) 설계 원칙

```
"이 에이전트가 파일을 수정해도 되는가?"

  YES → acceptEdits (자동 승인)
  NO  → plan (읽기 전용)

"이 에이전트가 평가자인가?"

  YES → 반드시 plan (독립성 보장)
  NO  → 역할에 따라 결정
```

**핵심**: 생산자와 평가자를 같은 권한으로 주면 안 된다. 평가자가 "고치면 되니까 PASS"라는 유혹에 빠진다.

---

## Layer 2: 라우팅 — "업무 프로세스 설계"

**이것이 에이전시 구축에서 가장 중요한 부분이다.**

### SKILL.md = 파이프라인 컨트롤러

라우팅은 코드가 아니라 **SKILL.md 파일에 자연어로 작성**한다. Claude(MoAI)가 이 문서를 읽고 지시대로 Agent()를 호출한다.

파일 위치: `.claude/skills/{에이전시명}/SKILL.md`

```yaml
---
name: my-agency
description: >
  나의 커스텀 에이전시 오케스트레이터.
  자연어 또는 서브커맨드를 전문 에이전트에게 라우팅한다.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion,
               TaskCreate, TaskUpdate, TaskList, TaskGet
user-invocable: true
metadata:
  version: "1.0.0"
  category: "agency"
---

## 실행 지시

### 서브커맨드 라우터

| 서브커맨드 | 동작 |
|-----------|------|
| `analyze` | 분석 파이프라인 전체 실행 |
| `report`  | 리포트 생성만 실행 |
| `review`  | 평가만 실행 |
| `learn`   | 학습 수집 |

### 파이프라인 실행 순서 (analyze)

Step 1: [사전 조건 확인]
Step 2: Agent(researcher) 호출 → 데이터 수집
Step 3: Agent(analyst) 호출 → 분석 수행
Step 4: Agent(writer) 호출 → 보고서 작성
Step 5: Agent(reviewer) 호출 → 품질 평가
Step 6: FAIL이면 → Step 4로 (최대 3회)
Step 7: PASS이면 → Agent(learner) 호출
```

### 라우팅 패턴 6가지

실제 에이전시를 설계할 때 조합해서 사용하는 기본 패턴:

#### 패턴 1: 순차 (Sequential)

```
A → B → C → D
```

가장 단순. 앞 단계의 출력이 다음 단계의 입력.

```
SKILL.md에서:
  Step 1: Agent(A) 호출 → result_a.md 생성
  Step 2: Agent(B) 호출 (result_a.md를 프롬프트에 포함) → result_b.md 생성
  Step 3: Agent(C) 호출 (result_b.md를 프롬프트에 포함) → result_c.md 생성
```

**사용처**: 각 단계가 이전 단계에 강하게 의존할 때

#### 패턴 2: 팬아웃/팬인 (Fan-out / Fan-in)

```
     ┌→ B ─┐
A →──┤     ├──→ D
     └→ C ─┘
```

A가 끝나면 B, C를 병렬 실행. 둘 다 끝나면 D에서 통합.

```
SKILL.md에서:
  Step 1: Agent(A) 호출 → brief.md 생성
  Step 2: Agent(B)와 Agent(C)를 동시에 호출 (run_in_background: true)
          → B는 output_b.md, C는 output_c.md 생성
  Step 3: 두 에이전트 완료 대기
  Step 4: Agent(D) 호출 (output_b.md + output_c.md를 프롬프트에 포함)
```

**사용처**: 독립적 관점의 병렬 작업 (Agency의 Copywriter + Designer)

#### 패턴 3: GAN Loop (생산-평가 반복)

```
     ┌──────────────┐
     │              │
     ▼              │
  Builder → Evaluator
              │
         PASS/FAIL?
              │
         PASS → 다음
```

```
SKILL.md에서:
  Step N: 반복 시작 (최대 5회)
    N-1: Agent(builder) 호출 → 산출물 생성
    N-2: Agent(evaluator) 호출 → score 확인
    N-3: score ≥ threshold → 반복 종료, 다음 단계로
    N-4: score < threshold → evaluator 피드백을 builder 프롬프트에 포함하여 재호출
    N-5: 5회 도달 → AskUserQuestion으로 사용자 개입
```

**사용처**: 품질이 중요한 산출물 (코드, 보고서, 디자인)

#### 패턴 4: 조건 분기 (Conditional)

```
      ┌── 조건 A → Agent X
입력 ──┤── 조건 B → Agent Y
      └── 조건 C → Agent Z
```

```
SKILL.md에서:
  Step N: 입력 분석
    - 입력이 "분석 요청"이면 → Agent(analyst) 호출
    - 입력이 "보고서 요청"이면 → Agent(writer) 호출
    - 입력이 "리뷰 요청"이면 → Agent(reviewer) 호출
```

**사용처**: 서브커맨드 라우팅, 도메인별 전문가 선택

#### 패턴 5: 가드 체크 (Guard / Pre-condition)

```
가드 확인 → 충족? → 파이프라인 진행
              │
            미충족 → 보정 에이전트 → 재확인
```

```
SKILL.md에서:
  Step 1: context/ 폴더 확인
    - 값이 "_TBD_"이면 → Agent(interviewer) 호출하여 컨텍스트 수집
    - 값이 채워져 있으면 → 다음 단계로 진행
```

**사용처**: 필수 데이터가 준비되었는지 확인 (Agency의 brand-voice.md 체크)

#### 패턴 6: 에스컬레이션 (Escalation)

```
자동 처리 시도 → 실패 → 더 강한 에이전트 시도 → 실패 → 사용자에게 위임
```

```
SKILL.md에서:
  Step N: Agent(haiku-analyst) 호출 → 결과 확인
    - 충분하면 → 다음 단계
    - 불충분하면 → Agent(sonnet-analyst) 호출 → 결과 확인
      - 충분하면 → 다음 단계
      - 불충분하면 → AskUserQuestion으로 사용자 판단 요청
```

**사용처**: 비용 최적화, 복잡도에 따른 단계적 대응

---

## Layer 3: 품질 게이트 — "QC 부서"

### Evaluator 설계 원칙

1. **반드시 읽기 전용** (`permissionMode: plan`)
2. **점수 체계를 명확히 정의** (어떤 차원을, 몇 점 만점으로, 어떤 가중치로)
3. **Hard Fail 조건 정의** (이것만 위반하면 무조건 FAIL)
4. **근거 없이 PASS 금지** (FROZEN zone에 명시)

### 평가 체계 설계 템플릿

```yaml
evaluation:
  dimensions:
    - name: "정확성"
      weight: 0.40
      description: "사실과 일치하는가, 오류가 없는가"
    - name: "완성도"
      weight: 0.30
      description: "요구사항이 모두 반영되었는가"
    - name: "품질"
      weight: 0.20
      description: "잘 구조화되어 있는가, 읽기 쉬운가"
    - name: "독창성"
      weight: 0.10
      description: "새로운 통찰이 있는가"

  hard_fail:
    - "핵심 데이터 오류"
    - "요구 섹션 누락"
    - "표절 또는 AI 슬롭"

  pass_threshold: 0.75
  max_iterations: 5
```

---

## Layer 4: 진화 시스템 — "조직 학습 부서"

### 최소 진화 시스템 구성

진화 시스템은 선택사항이지만, 반복 프로젝트에서 강력하다:

```
필수 요소:
  1. Learner 에이전트 (패턴 감지 + 제안 생성)
  2. learnings/ 폴더 (관찰 기록 저장)
  3. FROZEN/EVOLVABLE 경계 (각 에이전트 정의에)
  4. 졸업 기준 (몇 회 관찰, 어느 수준의 신뢰도)
  5. 사용자 승인 게이트 (자동 적용 방지)

선택 요소:
  6. Canary Check (시뮬레이션 검증)
  7. 신뢰도 감쇄 (90일 반감기)
  8. Anti-Pattern 즉시 차단
  9. 진화 속도 제한 (주 3회)
  10. 롤백 메커니즘
```

---

## 에이전트 간 통신 방식 선택

에이전시를 설계할 때 가장 중요한 아키텍처 결정 중 하나:

### 방식 1: 파일 기반 간접 통신 (Agency 방식)

```
Agent A → file_a.md 저장
                ↑
MoAI가 읽어서 → Agent B 프롬프트에 포함
```

| 장점 | 단점 |
|------|------|
| 단순하고 예측 가능 | 실시간 협업 불가 |
| 디버깅 쉬움 (파일 확인) | MoAI가 병목 |
| 에이전트 독립성 보장 | 대화형 교류 불가 |

**적합한 경우**: 단계가 명확히 분리되고, 순차적 파이프라인이 자연스러운 경우

### 방식 2: P2P SendMessage (Agent Teams 방식 - Stock Research)

```
Agent A ←SendMessage→ Agent B
Agent A ←SendMessage→ Agent C
```

| 장점 | 단점 |
|------|------|
| 실시간 교차 검증 | 복잡한 메시지 관리 |
| 에이전트 간 시너지 | 디버깅 어려움 |
| 병렬 협업 자연스러움 | Agent Teams 실험 기능 필요 |

**적합한 경우**: 여러 전문가가 같은 대상을 동시에 분석하고 서로의 발견이 영향을 줄 때

### 방식 3: 하이브리드 (추천)

```
Phase 1: 파일 기반 (기획 → 실행 전달)
Phase 2: P2P SendMessage (실행 중 전문가 협업)
Phase 3: 파일 기반 (실행 → 평가 전달)
```

**적합한 경우**: 대규모 에이전시에서 단계는 순차적이지만, 각 단계 내부에서 협업이 필요할 때

---

## 실전: 커스텀 에이전시 구축 단계

### Step 1: 도메인과 워크플로우 정의

```
질문 1: "이 에이전시가 무엇을 생산하는가?"
  → 예: 투자 보고서, 기술 문서, 교육 콘텐츠, 공정 파라미터

질문 2: "현실에서 이 일을 어떤 순서로 하는가?"
  → 예: 자료 수집 → 분석 → 초안 작성 → 검토 → 수정 → 최종본

질문 3: "어떤 전문가가 필요한가?"
  → 예: 리서처, 애널리스트, 라이터, 리뷰어

질문 4: "품질을 어떻게 판단하는가?"
  → 예: 정확성, 완성도, 독창성, 실용성
```

### Step 2: 파일 구조 생성

```
프로젝트/
├── .claude/
│   ├── agents/
│   │   └── {에이전시명}/
│   │       ├── researcher.md
│   │       ├── analyst.md
│   │       ├── writer.md
│   │       ├── reviewer.md
│   │       └── learner.md
│   ├── skills/
│   │   ├── {에이전시명}/
│   │   │   └── SKILL.md          ← 라우팅 로직 (핵심!)
│   │   ├── {에이전시명}-research/
│   │   │   └── SKILL.md          ← 리서치 방법론
│   │   └── {에이전시명}-evaluation/
│   │       └── SKILL.md          ← 평가 기준
│   └── rules/
│       └── {에이전시명}/
│           └── constitution.md   ← 불변 규칙
│
└── .{에이전시명}/
    ├── config.yaml               ← 파이프라인 설정
    ├── context/                   ← 도메인 컨텍스트
    │   ├── domain-knowledge.md
    │   ├── quality-criteria.md
    │   └── output-standards.md
    ├── templates/                 ← 입력/출력 템플릿
    ├── learnings/                 ← 학습 축적
    └── evolution/                 ← 진화 이력
```

### Step 3: 라우팅 SKILL.md 작성

이것이 **가장 중요한 파일**이다. 예시:

```yaml
---
name: my-research-agency
description: >
  커스텀 리서치 에이전시. 주제 분석 → 자료 수집 → 분석 → 보고서 → 검증 파이프라인.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion,
               TaskCreate, TaskUpdate, TaskList, TaskGet, WebSearch, WebFetch
user-invocable: true
---

## 실행 지시

### 서브커맨드 라우터

| 서브커맨드 | 동작 |
|-----------|------|
| `research` | 전체 파이프라인 실행 |
| `collect`  | 자료 수집만 |
| `analyze`  | 분석만 (기존 자료 기반) |
| `report`   | 보고서 생성만 |
| `review`   | 검증만 |
| `learn`    | 학습 수집 |

### 파이프라인: research

Step 1: .{에이전시}/context/ 확인.
  - domain-knowledge.md가 비어있으면 AskUserQuestion으로 도메인 정보 수집.

Step 2: 주제 분석.
  - 사용자 요청을 파싱하여 연구 범위, 핵심 질문, 기대 산출물 정리.

Step 3: Agent(researcher) 호출. run_in_background: true로 병렬 가능.
  - 프롬프트에 주제, 범위, 핵심 질문 포함.
  - 출력: _workspace/01-research-data.md

Step 4: Agent(analyst) 호출.
  - 프롬프트에 01-research-data.md 내용 포함.
  - 출력: _workspace/02-analysis.md

Step 5: Agent(writer) 호출.
  - 프롬프트에 02-analysis.md 내용 포함.
  - 출력: _workspace/03-draft-report.md

Step 6: GAN Loop 시작 (최대 3회).
  Step 6-1: Agent(reviewer) 호출. permissionMode: plan.
    - 프롬프트에 03-draft-report.md + 원래 요구사항 포함.
    - 출력: _workspace/04-review.md (점수 + 피드백)
  Step 6-2: 점수 확인.
    - score ≥ 0.80 → PASS → Step 7로
    - score < 0.80 → FAIL → reviewer 피드백을 writer 프롬프트에 포함하여 재호출
    - 3회 도달 → AskUserQuestion

Step 7: Agent(learner) 호출 (점수 < 1.0일 때만).
  - review 결과에서 패턴 감지.
  - 학습 기록을 .{에이전시}/learnings/에 저장.

Step 8: 최종 보고서를 사용자에게 제시.
```

### Step 4: 에이전트 개별 정의

각 에이전트의 `.md` 파일을 작성한다. 핵심은 **FROZEN/EVOLVABLE 경계**:

```markdown
---
name: my-analyst
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
model: sonnet
permissionMode: acceptEdits
skills:
  - my-research-agency-analysis
---

# Analyst

## FROZEN ZONE
### Identity
너는 리서치 에이전시의 분석가이다. 수집된 데이터를 구조화하고,
패턴을 식별하고, 인사이트를 도출한다.

### Ethical Boundaries
- 데이터에 없는 결론을 만들지 않는다
- 불확실한 정보는 신뢰도를 표기한다
- 상관관계를 인과관계로 포장하지 않는다

## EVOLVABLE ZONE
### Analysis Framework
(Learner가 개선할 수 있는 영역)
- 기본 분석 프레임워크: SWOT
- 데이터 분류 체계: 정량/정성 구분
```

### Step 5: 컨텍스트 문서 작성

`.{에이전시}/context/` 폴더에 도메인 지식을 정리한다:

```markdown
# domain-knowledge.md

## 이 에이전시의 전문 분야
(분석 대상, 산업, 기술 영역 등)

## 핵심 용어 정의
(에이전트들이 일관되게 사용해야 하는 용어)

## 참고 자료 목록
(항상 참조해야 하는 데이터 소스)
```

### Step 6: 테스트 실행 및 반복

```bash
# 첫 실행
/my-research-agency research "테스트 주제"

# 결과 확인 후 조정
# - 에이전트 프롬프트 수정
# - 평가 기준 조정
# - 라우팅 순서 변경
# - 필요한 에이전트 추가/제거
```

---

## 다중 에이전시 아키텍처: "그룹사" 구조

여러 에이전시를 동시에 운영하고 조합하는 구조:

```
┌──────────────────────────────────────────────────────────┐
│                    MoAI (지주회사/CEO)                      │
│                                                           │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│   │ Research    │  │ Web Agency  │  │ Doc Agency  │      │
│   │ Agency     │  │             │  │             │      │
│   │            │  │ Planner     │  │ Planner     │      │
│   │ Researcher │  │ Copywriter  │  │ Writer      │      │
│   │ Analyst    │  │ Designer    │  │ Diagrammer  │      │
│   │ Critic     │  │ Builder     │  │ Builder     │      │
│   │ Presenter  │  │ Evaluator   │  │ Reviewer    │      │
│   │            │  │ Learner     │  │ Learner     │      │
│   └─────────────┘  └─────────────┘  └─────────────┘      │
│         │                │                │               │
│         └────────────────┼────────────────┘               │
│                          │                                │
│                  "리서치 결과를 바탕으로                     │
│                   웹사이트와 문서를 만들어줘"                │
│                          │                                │
│                   MoAI가 3개 에이전시를                     │
│                   순차적으로 호출                           │
└──────────────────────────────────────────────────────────┘
```

### 에이전시 간 연결 방법

```
SKILL.md (최상위 오케스트레이터):

Step 1: Skill("research-agency") 호출 → 리서치 보고서 생성
Step 2: 리서치 보고서를 읽어서 → Skill("web-agency") 호출 (보고서 기반 웹사이트 제작)
Step 3: 리서치 보고서를 읽어서 → Skill("doc-agency") 호출 (보고서 기반 기술 문서 제작)
```

각 에이전시는 **독립적으로도 실행 가능**하고, **조합해서도 실행 가능**하다.

---

## 조직 설계 체크리스트

새 에이전시를 만들기 전에 확인:

### 1. 역할 분리가 명확한가?

```
[ ] 각 에이전트가 하나의 역할에 집중하는가
[ ] 생산자와 평가자가 분리되어 있는가
[ ] 기획/전략은 별도 에이전트인가
```

### 2. 라우팅이 정의되어 있는가?

```
[ ] SKILL.md에 파이프라인 순서가 명시되어 있는가
[ ] 서브커맨드가 정의되어 있는가
[ ] 조건 분기(PASS/FAIL, 가드 체크)가 있는가
[ ] 에스컬레이션 경로가 있는가
```

### 3. 품질 게이트가 있는가?

```
[ ] 평가 차원과 가중치가 정의되어 있는가
[ ] Hard Fail 조건이 있는가
[ ] GAN Loop 반복 횟수와 탈출 조건이 있는가
```

### 4. 컨텍스트가 문서화되어 있는가?

```
[ ] 도메인 지식이 context/ 폴더에 있는가
[ ] 에이전트마다 필요한 스킬이 주입되어 있는가
[ ] 용어와 규약이 통일되어 있는가
```

### 5. 안전장치가 있는가?

```
[ ] FROZEN/EVOLVABLE 경계가 각 에이전트에 있는가
[ ] constitution.md에 불변 규칙이 있는가
[ ] 평가자가 읽기 전용인가
```

### 6. (선택) 진화 시스템이 있는가?

```
[ ] Learner 에이전트가 있는가
[ ] 학습 축적 경로(learnings/)가 있는가
[ ] 졸업 기준이 정의되어 있는가
[ ] 사용자 승인 게이트가 있는가
```

---

## 기억해야 할 것

1. **SKILL.md가 파이프라인의 "코드"이다** — 에이전트가 아니라 SKILL.md가 흐름을 결정한다
2. **에이전트는 서로를 모른다** — MoAI가 파일을 읽어서 다음 에이전트에 전달한다
3. **생산자와 평가자를 절대 합치지 마라** — 독립적 검증이 품질의 핵심이다
4. **컨텍스트 문서가 조직 문화이다** — 에이전트의 행동은 프롬프트보다 컨텍스트로 제어한다
5. **점진적으로 시작하라** — 3개 에이전트 + 순차 파이프라인으로 시작, 필요에 따라 확장
