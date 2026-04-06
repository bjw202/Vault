# AI Agency 응용 사례

## 현재 구조의 직접 활용

### 사례 1: 개인 포트폴리오 사이트

```
상황: 프리랜서 개발자가 자기 포트폴리오 사이트를 만들고 싶다

실행: /agency brief
  → Planner가 인터뷰: "어떤 프로젝트를 보여줄 건가요? 주요 타겟은?"
  → Copywriter가 자기소개, 프로젝트 설명, 연락처 카피 작성
  → Designer가 개발자 포트폴리오에 맞는 깔끔한 디자인 시스템 설계
  → Builder가 Next.js로 구현
  → Evaluator가 반응형, 접근성, 성능 검증

장점: 일관된 톤과 디자인으로 전문적인 사이트 완성
소요: 에이전트 실행 1회 (GAN Loop 포함 약 15-30분)
```

### 사례 2: 스타트업 랜딩페이지

```
상황: MVP 출시 전 프로덕트 헌트 등록용 랜딩페이지 필요

실행: /agency brief
  → brand-voice.md에 "자신감 있고 간결한 톤" 설정
  → Copywriter가 구체적 수치 포함 카피 ("47분 → 12분")
  → Designer가 레퍼런스 사이트 기반 디자인
  → Builder가 구현 + Vercel 배포 설정
  → Evaluator가 Lighthouse 90+ 검증

장점: 프로덕트 헌트에 올려도 부끄럽지 않은 품질
반복: 다음 랜딩페이지 때 brand-voice.md 재사용 → 일관된 브랜드
```

### 사례 3: SaaS 다중 페이지 웹사이트

```
상황: 로그인, 대시보드, 설정 페이지가 있는 SaaS 웹앱

실행: /agency brief → 타입을 "web-app"으로 설정
  → Planner가 각 페이지별 요구사항 정리
  → Copywriter가 빈 상태 메시지, 에러 메시지까지 작성
  → Designer가 대시보드용 컴포넌트 시스템 설계
  → Builder가 페이지별 구현 (인증은 Clerk 연동)
  → Evaluator가 사용자 플로우 전체 테스트

장점: 페이지 간 일관된 UX, 엣지 케이스 카피까지 커버
```

---

## 이 구조를 다른 도메인에 응용하기

AI Agency의 핵심 패턴은 특정 도메인에 종속되지 않는다. **파이프라인 구조, GAN Loop, 자기진화**는 다른 영역에도 적용할 수 있다.

### 응용 패턴 A: 투자 리서치 하네스

이미 이 프로젝트에 있는 Stock Research 하네스와 결합하는 시나리오:

```
Agency 패턴                    투자 리서치 적용
─────────────                  ─────────────────
Planner (기획)          →      Research Planner (리서치 주제/범위 기획)
Copywriter (카피)       →      6명 Analyst (병렬 분석)
Designer (디자인)       →      (병합 — 분석에 디자인 불필요)
Builder (구현)          →      Report Builder (보고서 작성)
Evaluator (평가)        →      Devil's Advocate (독립 검증)
Learner (학습)          →      Research Learner (분석 패턴 학습)
```

**가져올 수 있는 것:**
- GAN Loop → Report Builder가 보고서 작성 → Devil이 평가 → 수정 반복
- 자기진화 → "매번 환율 리스크를 빠뜨린다" → 규칙으로 승격
- Anti-Pattern → "근거 없는 낙관적 전망"을 즉시 차단

### 응용 패턴 B: 기술 문서 제작 하네스

```
Agency 패턴                    기술 문서 적용
─────────────                  ─────────────────
Planner (기획)          →      Doc Planner (문서 구조 설계)
Copywriter (카피)       →      Technical Writer (내용 작성)
Designer (디자인)       →      Diagram Designer (아키텍처 다이어그램)
Builder (구현)          →      Doc Builder (Nextra/MkDocs 사이트 생성)
Evaluator (평가)        →      Doc Evaluator (정확성, 완성도 검증)
Learner (학습)          →      Doc Learner (문서 스타일 패턴 학습)

brand-voice.md         →      docs-style.md (문서 톤 & 용어 정리)
visual-identity.md     →      diagram-style.md (다이어그램 스타일)
```

### 응용 패턴 C: 교육 콘텐츠 제작 하네스

```
Agency 패턴                    교육 콘텐츠 적용
─────────────                  ─────────────────
Planner (기획)          →      Curriculum Planner (커리큘럼 설계)
Copywriter (카피)       →      Content Writer (강의 내용 작성)
Designer (디자인)       →      Slide Designer (프레젠테이션 디자인)
Builder (구현)          →      Course Builder (LMS 콘텐츠 조립)
Evaluator (평가)        →      Pedagogy Evaluator (교육 효과 평가)
Learner (학습)          →      Course Learner (학습자 피드백 반영)

brand-voice.md         →      teaching-voice.md (강의 톤)
target-audience.md     →      learner-profile.md (학습자 수준/배경)
```

### 응용 패턴 D: 마케팅 캠페인 하네스

```
Agency 패턴                    마케팅 적용
─────────────                  ─────────────────
Planner (기획)          →      Campaign Planner (캠페인 전략)
Copywriter (카피)       →      Ad Copywriter (광고 카피)
Designer (디자인)       →      Creative Designer (배너/소셜 이미지)
Builder (구현)          →      Campaign Builder (이메일 템플릿, LP)
Evaluator (평가)        →      Campaign Evaluator (A/B 테스트 설계 검증)
Learner (학습)          →      Campaign Learner (CTR 패턴 학습)
```

### 응용 패턴 E: 레이저 가공 파라미터 최적화 하네스

jw님의 레이저 가공 업무에 맞춘 응용:

```
Agency 패턴                    레이저 가공 적용
─────────────                  ─────────────────
Planner (기획)          →      Process Planner (소재/두께/목표 정의)
Copywriter (카피)       →      Parameter Researcher (논문/데이터 기반 초기값)
Designer (디자인)       →      Process Designer (파라미터 조합 설계)
Builder (구현)          →      Experiment Builder (실험 계획서 작성)
Evaluator (평가)        →      Quality Evaluator (컷 품질 평가 기준 적용)
Learner (학습)          →      Process Learner (소재별 최적 파라미터 축적)

brand-voice.md         →      process-standards.md (품질 기준)
visual-identity.md     →      (불필요)
target-audience.md     →      material-catalog.md (소재 데이터베이스)
tech-preferences.md    →      equipment-specs.md (장비 스펙)
quality-standards.md   →      cut-quality-criteria.md (컷 품질 기준)
```

**이 구조의 장점:**
- GAN Loop → 파라미터 제안 → 품질 평가 → 수정 반복
- 자기진화 → "SUS304 1mm에서 N2 가스가 O2보다 버 적음" → 규칙 축적
- Anti-Pattern → "이 출력/속도 조합은 소재 변형 발생" → 즉시 차단

---

## 자기진화가 특히 유용한 상황

자기진화 시스템은 **반복적이고 유사한 프로젝트**를 할 때 가장 효과적이다:

| 상황 | 자기진화 효과 |
|------|-------------|
| **에이전시 업무** — 비슷한 형태의 랜딩페이지를 반복 제작 | 매 프로젝트마다 같은 실수를 줄여감 |
| **사내 도구** — 여러 팀의 대시보드를 동일 스택으로 제작 | 컴포넌트 패턴이 점점 정교해짐 |
| **기술 문서** — 여러 API의 문서를 같은 형식으로 작성 | 문서 구조와 용어가 자동 통일 |
| **리서치 보고서** — 같은 산업의 종목을 반복 분석 | 분석 프레임워크가 점점 정밀해짐 |

**자기진화가 덜 유용한 상황:**
- 일회성 프로젝트 (학습할 기회가 없음)
- 매번 완전히 다른 도메인 (패턴이 이전 불가)
- 초기 단계에서 방향이 자주 바뀌는 프로젝트

---

## 응용 패턴 F: 기업 내부 지식 관리 에이전시

조직의 지식을 체계적으로 수집, 정리, 배포하는 가상 "지식경영팀":

```
Agency 패턴                    지식 관리 적용
─────────────                  ─────────────────
Planner (기획)          →      Knowledge Planner (지식 영역 분류/우선순위)
Copywriter (카피)       →      Knowledge Collector (현업 인터뷰/문서 수집)
Designer (디자인)       →      Knowledge Architect (지식 구조 설계/분류 체계)
Builder (구현)          →      Knowledge Builder (위키/문서 시스템 구축)
Evaluator (평가)        →      Knowledge Auditor (정확성/최신성/접근성 평가)
Learner (학습)          →      Knowledge Optimizer (검색 패턴/활용도 학습)

context/ 폴더:
  domain-taxonomy.md     ← 지식 분류 체계
  quality-criteria.md    ← 문서 품질 기준
  audience-map.md        ← 지식 소비자 그룹별 니즈
  tool-preferences.md    ← Notion/Confluence/위키 등 도구
```

---

## 에이전시 조합: 복합 워크플로우

단일 에이전시가 아니라, **여러 에이전시를 조합**하는 시나리오:

### 시나리오: "리서치 → 웹사이트 → 문서" 원스톱

```
사용자: "레이저 가공 기술 트렌드 조사하고, 결과를 웹사이트와 기술 문서로 만들어줘"

MoAI (최상위 오케스트레이터):
  Step 1: Research Agency 호출
    → 트렌드 리서치 보고서 생성
  
  Step 2: 보고서를 Web Agency의 BRIEF로 변환
    → 리서치 결과 기반 웹사이트 제작
  
  Step 3: 보고서를 Doc Agency의 입력으로 전달
    → 기술 문서 + 프레젠테이션 생성
```

**핵심**: 각 에이전시는 독립적으로도 실행 가능하지만, 상위 오케스트레이터가 **출력물을 다음 에이전시의 입력으로 연결**하면 복합 워크플로우가 된다.

### 시나리오: "분석 → 의사결정 보조 → 실행"

jw님의 트레이딩 + 레이저 가공에 적용:

```
[Market Research Agency]
  → 종목 분석 보고서
       │
       ▼
[Decision Support Agency]
  → 매매 의사결정 보조 (진입/청산 시점, 포지션 사이징)
       │
       ▼ (별도 도메인)
[Process Optimization Agency]
  → 레이저 가공 파라미터 최적화
       │
       ▼
[Documentation Agency]
  → 가공 결과 보고서 + 파라미터 데이터베이스 업데이트
```

---

## 핵심 응용 원칙

Agency 패턴을 다른 도메인에 응용할 때의 핵심 원칙:

### 1. 역할을 분리하라

하나의 에이전트에 너무 많은 역할을 주지 말라. "기획 + 실행 + 검증"을 한 에이전트에 넣으면 자기 검증이 불가능하다.

### 2. 생산자와 평가자를 분리하라 (GAN Loop)

만드는 사람(Builder)과 평가하는 사람(Evaluator)을 반드시 분리하라. 평가자는 **읽기 전용**(plan 모드)으로 설정하여 독립성을 보장하라.

### 3. 컨텍스트를 코드가 아닌 문서로 공유하라

`.agency/context/`처럼 **사람이 읽고 수정할 수 있는 문서**로 에이전트의 행동을 규정하라. 코드 속에 하드코딩하면 수정이 어렵다.

### 4. FROZEN/EVOLVABLE 경계를 명확히 하라

절대 바뀌면 안 되는 것(정체성, 안전 규칙)과 진화 가능한 것(작업 방식, 선호도)을 구분하라.

### 5. 진화 속도를 제한하라

빠른 진화는 불안정을 초래한다. 주 3회, 24시간 간격, 5회 관찰 같은 제한은 안정적 개선을 보장한다.

### 6. 에이전시를 "부서"로, 에이전트를 "직원"으로 설계하라

Claude Code를 코딩 도구가 아닌 **조직 구축 플랫폼**으로 보면, 자연스러운 설계가 나온다:
- 에이전시 = 부서 (독립적 업무 단위)
- SKILL.md = SOP (표준 업무 절차)
- 에이전트 = 직원 (전문 역할)
- context/ = 사규 (조직 문화/기준)
- config.yaml = 운영 규정
- constitution.md = 정관

### 7. 점진적으로 확장하라

```
Phase 1: 3개 에이전트 + 순차 파이프라인 (최소 동작)
Phase 2: Evaluator 추가 + GAN Loop (품질 보증)
Phase 3: Learner 추가 + 진화 시스템 (자기 개선)
Phase 4: 다른 에이전시와 조합 (복합 워크플로우)
```
