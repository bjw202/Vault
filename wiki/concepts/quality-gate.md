---
type: concept
topic: ai-agency
concepts:
  - gan-loop
  - multi-agent-systems
aliases:
  - 품질 게이트
  - evaluator
  - 평가 시스템
  - PASS/FAIL 기준
sources:
  - raw/03-how-it-works.md
  - raw/07-build-your-own-agency.md
  - raw/STOCK_RESEARCH_ARCHITECTURE.md
updated: 2026-04-06
---

# Quality Gate

## Summary

멀티 에이전트 파이프라인에서 산출물이 기준을 충족하는지 독립적으로 검증하는 메커니즘. Evaluator/Devil's Advocate가 이 역할을 수행한다.

## Key Takeaways

- Evaluator 설계 원칙: 반드시 읽기 전용(plan 모드), 점수 체계 명확 정의, Hard Fail 조건 정의
- Agency 4차원 점수: Design(30%), Originality(25%), Completeness(25%), Functionality(20%)
- Hard Fail: 카피 변경, AI 슬롭, 모바일 깨짐, 404 링크
- Stock Research: Devil's Advocate가 6명의 결론을 모두 읽고 독립 반박
- 생산자와 평가자 분리가 핵심 — 같은 에이전트가 둘 다 하면 "고치면 되니까 PASS" 유혹
- 평가 체계 설계 시: 차원별 가중치, Hard Fail 조건, pass_threshold, max_iterations 정의

## Sources

- [[ai-agency-how-it-works]]
- [[ai-agency-build-your-own]]
- [[stock-research-architecture]]

## Related Concepts

- [[gan-loop]]
- [[multi-agent-systems]]

## Related Pages

- [[ai-agency-architecture]]
