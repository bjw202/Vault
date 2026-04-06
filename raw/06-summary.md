# AI Agency 요약 카드

## 한 장 요약

```
┌─────────────────────────────────────────────────────────────┐
│  AI Agency v3.2 — Self-Evolving Web & App Production Harness│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  무엇?  웹 에이전시 파이프라인을 AI로 자동화한 시스템          │
│                                                             │
│  왜?    역할 분리 → 품질 향상 + GAN Loop → 반복 검증         │
│         + 브랜드 일관성 + 자기진화                            │
│                                                             │
│  누가?  6개 AI 에이전트 (Planner → Copywriter & Designer     │
│         → Builder ↔ Evaluator → Learner)                    │
│                                                             │
│  어디?  MoAI-ADK 위에서 동작하는 특화 레이어                  │
│         .claude/agents/agency/ + .agency/                    │
│                                                             │
│  어떻게? /agency brief → 인터뷰 → 카피 → 디자인 → 코드       │
│         → 평가 → 학습 (전 과정 자동)                          │
│                                                             │
│  응용?  기술문서, 교육콘텐츠, 마케팅, 리서치, 공정 최적화 등   │
│         "생산 → 평가 → 개선" 반복이 있는 모든 도메인           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 핵심 숫자

| 항목 | 값 |
| --- | --- |
| 에이전트 수 | 6개 |
| 스킬 수 | 5개 (agency 전용) |
| GAN Loop 최대 반복 | 5회 |
| 합격 기준 | 0.75 (100점 만점 75점) |
| 최소 합격 기준 (절대 하한) | 0.60 (헌법에 의해 보호) |
| 평가 차원 | 4개 (Design 30%, Originality 25%, Completeness 25%, Functionality 20%) |
| Hard Fail 조건 | 4개 (카피 변경, AI 슬롭, 모바일 깨짐, 404 링크) |
| 진화 속도 제한 | 주 3회, 24시간 간격 |
| 학습 규칙 승격 조건 | 5회 관찰 + 신뢰도 80% |
| 신뢰도 반감기 | 90일 |
| 활성 학습 최대 | 50개 |
| 안전 레이어 | 5층 |
| 브랜드 컨텍스트 파일 | 5개 |
| Opus 에이전트 | 2개 (Planner, Learner) |
| Sonnet 에이전트 | 4개 (Copywriter, Designer, Builder, Evaluator) |

---

## 파일 구조 한눈에

```
프로젝트/
├── .claude/agents/agency/     ← 에이전트 정의 6개
├── .claude/skills/agency-*/   ← 전용 스킬 5개
├── .claude/rules/agency/      ← 헌법 (변경 불가 규칙)
└── .agency/
    ├── config.yaml            ← 파이프라인/진화 설정
    ├── fork-manifest.yaml     ← MoAI 포크 추적
    ├── context/               ← 브랜드 컨텍스트 5개 (사용자만 수정)
    ├── templates/             ← BRIEF 템플릿
    ├── briefs/                ← 생성된 기획서
    ├── learnings/             ← 학습 패턴 축적
    └── evolution/             ← 진화 이력/스냅샷/롤백 로그
```

---

## 문서 목록

| \# | 파일명 | 내용 |
| --- | --- | --- |
| 01 | [01-what-is-agency.md](./01-what-is-agency.md) | Agency란 무엇인가? 실제 에이전시 비유, MoAI와의 관계, 적합한 프로젝트 |
| 02 | [02-architecture.md](./02-architecture.md) | **파이프라인 라우팅 상세**, 입출력 관계, 파일 시스템, 브랜드 컨텍스트, 설정 해설 |
| 03 | [03-how-it-works.md](./03-how-it-works.md) | 실제 사용 시나리오, 데이터 흐름, 모델 배정, 권한 모드, 안전장치 |
| 04 | [04-self-evolution.md](./04-self-evolution.md) | 자기진화 파이프라인, 신뢰도 감쇄, Anti-Pattern, FROZEN/EVOLVABLE 경계 |
| 05 | [05-use-cases.md](./05-use-cases.md) | 직접 활용 사례, 6가지 도메인 응용 패턴, **에이전시 조합 복합 워크플로우** |
| 06 | [06-summary.md](./06-summary.md) | 한 장 요약, 핵심 숫자, 파일 구조, 문서 목록 (이 파일) |
| **07** | [**07-build-your-own-agency.md**](./07-build-your-own-agency.md) | **나만의 에이전시 구축 가이드: 4-Layer 설계, 6가지 라우팅 패턴, 다중 에이전시 아키텍처** |

---

## 이 문서의 관점

> Claude Code는 코딩 도구가 아니다. **에이전트를 정의하고, 역할을 부여하고, 워크플로우를 제어하여 "지식 조직"을 만드는 플랫폼**이다.
>
> - 에이전시 = 부서 (독립적 업무 단위)
> - SKILL.md = SOP (표준 업무 절차, **라우팅의 핵심**)
> - 에이전트 = 직원 (역할, 전문성, 도구, 권한)
> - context/ = 사규 (조직 문화/기준)
> - Learner = 조직 학습 부서

---

## 한 문장 정리

> **AI Agency는 "기획 → 카피 → 디자인 → 코딩 → 품질검증"의 웹 에이전시 워크플로우를 6개 AI 전문가에게 위임하고, GAN Loop로 품질을 보증하며, 프로젝트를 반복할수록 스스로 더 나아지는 자기진화 시스템이다. 이 패턴은 어떤 도메인에서든 "생산 → 평가 → 개선" 반복이 필요한 조직을 만드는 데 응용할 수 있다.**