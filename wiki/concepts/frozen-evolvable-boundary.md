---
type: concept
topic: ai-agency
concepts:
  - self-evolution
  - multi-agent-systems
aliases:
  - FROZEN/EVOLVABLE 경계
  - frozen zone
  - evolvable zone
  - 불변/가변 경계
sources:
  - raw/03-how-it-works.md
  - raw/04-self-evolution.md
  - raw/07-build-your-own-agency.md
updated: 2026-04-06
---

# FROZEN/EVOLVABLE Boundary

## Summary

에이전트 정의에서 절대 변경 불가능한 영역(FROZEN)과 학습을 통해 개선 가능한 영역(EVOLVABLE)을 명확히 구분하는 설계 원칙.

## Key Takeaways

- **FROZEN Zone** — Learner도 절대 수정 불가:
  - Identity: 에이전트 정체성
  - Safety Rails: 안전 규칙 (진화 속도 제한, 승인 요구 등)
  - Ethical Boundaries: 윤리 경계 (카피 변경 금지, 다크 패턴 금지 등)
- **EVOLVABLE Zone** — Learner가 수정 제안 가능:
  - Framework Preferences: 도구/프레임워크 선호
  - Code Patterns: 코드 패턴 규칙
  - Style Guidelines: 스타일 가이드
  - Output Patterns: 출력 형식
- FROZEN은 에이전트의 "본질"을 보호, EVOLVABLE은 "작업 방식 개선"을 허용
- 이 경계가 없으면 Builder가 "카피도 수정할게요"로 역할 침범 가능

## Sources

- [[ai-agency-how-it-works]]
- [[ai-agency-self-evolution]]
- [[ai-agency-build-your-own]]

## Related Concepts

- [[self-evolution]]
- [[multi-agent-systems]]
