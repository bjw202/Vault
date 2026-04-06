---
type: source
topic: ai-agency
concepts:
  - multi-agent-systems
  - pipeline-routing
  - gan-loop
  - self-evolution
aliases: []
source_file: raw/01-what-is-agency.md
updated: 2026-04-06
checksum: 94b13313e37c9d872a086f7347b5b9f519c858f48c9736a46dee8db68aabb072
---

# AI Agency란 무엇인가?

## Summary

AI Agency는 웹 에이전시의 작업 방식(기획→카피→디자인→코딩→품질검증)을 6개 AI 에이전트로 자동화한 시스템이다. MoAI-ADK 위에서 동작하는 웹 제작 특화 하네스이며, GAN Loop와 자기진화 메커니즘을 갖추고 있다.

## Key Takeaways

- 6개 전문 에이전트: Planner, Copywriter, Designer, Builder, Evaluator, Learner
- 역할 분리가 핵심 — 하나의 LLM에 모든 역할을 맡기지 않음
- GAN Loop: Builder(생산) ↔ Evaluator(평가) 반복으로 품질 보증
- 브랜드 컨텍스트(`.agency/context/`)로 일관성 유지
- Learner가 프로젝트마다 패턴을 학습하여 자기진화
- MoAI는 범용 개발 프레임워크, Agency는 그 위의 웹 제작 특화 레이어

## Sources

- `raw/01-what-is-agency.md`

## Related Concepts

- [[multi-agent-systems]]
- [[pipeline-routing]]
- [[gan-loop]]
- [[self-evolution]]

## Related Pages

- [[ai-agency-architecture]]
- [[ai-agency-how-it-works]]
- [[ai-agency-summary]]

## Open Questions

- MoAI-ADK 자체의 상세 아키텍처는 이 문서에 포함되어 있지 않음
