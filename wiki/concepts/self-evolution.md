---
type: concept
topic: ai-agency
concepts:
  - frozen-evolvable-boundary
  - multi-agent-systems
aliases:
  - 자기진화
  - self-evolving agents
  - 에이전트 진화
  - learner system
sources:
  - raw/04-self-evolution.md
  - raw/05-use-cases.md
updated: 2026-04-06
---

# Self-Evolution

## Summary

Learner 에이전트가 프로젝트 반복을 통해 패턴을 감지하고, 다른 에이전트의 EVOLVABLE Zone을 점진적으로 개선하는 메커니즘.

## Key Takeaways

- 학습 파이프라인: 관찰(1회) → 휴리스틱(3회) → 규칙 후보(5회) → 고신뢰(10회+)
- 졸업 심사: 5회 관찰 + 신뢰도 80% + 일관성 80% + 모순 없음 + 30일 이내
- 신뢰도 감쇄: 90일 반감기, 0.30 미만이면 폐기 후보
- Anti-Pattern: 1회라도 치명적이면 즉시 FROZEN, 사람만 해제 가능
- 진화 속도 제한: 주 3회, 24시간 간격, 활성 학습 최대 50개
- Canary Check: 진화 전에 과거 3개 프로젝트로 시뮬레이션, 0.10 이상 하락 시 차단
- 반복적/유사한 프로젝트에서 가장 효과적
- Fork Manifest로 MoAI 원본과의 분화 정도 추적

## Sources

- [[ai-agency-self-evolution]]
- [[ai-agency-use-cases]]

## Related Concepts

- [[frozen-evolvable-boundary]]
- [[multi-agent-systems]]

## Related Pages

- [[ai-agency-build-your-own]]
