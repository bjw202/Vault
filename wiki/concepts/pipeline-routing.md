---
type: concept
topic: ai-agency
concepts:
  - multi-agent-systems
aliases:
  - 파이프라인 라우팅
  - 라우팅 패턴
  - routing patterns
  - 워크플로우 제어
sources:
  - raw/02-architecture.md
  - raw/07-build-your-own-agency.md
  - raw/STOCK_RESEARCH_ARCHITECTURE.md
updated: 2026-04-06
---

# Pipeline Routing

## Summary

멀티 에이전트 시스템에서 "누가, 어떤 순서로, 어떤 조건에서" 실행되는지를 제어하는 메커니즘. SKILL.md 파일이 선언적 파이프라인 스크립트 역할을 한다.

## Key Takeaways

- SKILL.md가 라우팅의 핵심 — 코드가 아니라 자연어로 작성
- 6가지 라우팅 패턴:
  - **Sequential**: A → B → C (단순 순차)
  - **Fan-out/Fan-in**: A → [B, C 병렬] → D (병렬 후 통합)
  - **GAN Loop**: Builder ↔ Evaluator 반복 (품질 보증)
  - **Conditional**: 입력 조건에 따라 다른 에이전트 호출
  - **Guard/Pre-condition**: 필수 데이터 확인 후 진행
  - **Escalation**: haiku → sonnet → 사용자 순으로 단계적 대응
- Agency: MoAI가 순차 호출 (3계층 라우팅)
- Stock Research: 팬아웃/팬인 + 2-Phase (6병렬 → 1순차)

## Sources

- [[ai-agency-architecture]]
- [[ai-agency-build-your-own]]
- [[stock-research-architecture]]

## Related Concepts

- [[multi-agent-systems]]
- [[gan-loop]]

## Related Pages

- [[ai-agency-how-it-works]]
