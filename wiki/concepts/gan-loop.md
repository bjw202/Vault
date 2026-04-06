---
type: concept
topic: ai-agency
concepts:
  - multi-agent-systems
  - quality-gate
aliases:
  - GAN Loop
  - 생산-평가 반복
  - Builder-Evaluator Loop
  - 적대적 품질 루프
sources:
  - raw/01-what-is-agency.md
  - raw/02-architecture.md
  - raw/03-how-it-works.md
updated: 2026-04-06
---

# GAN Loop

## Summary

GAN(Generative Adversarial Network)에서 영감을 받은 품질 보증 구조. Generator(Builder)가 산출물을 만들고 Discriminator(Evaluator)가 판별하여, 기준 점수에 도달할 때까지 반복한다.

## Key Takeaways

- Builder = Generator, Evaluator = Discriminator
- 탈출 조건: 점수 ≥ 0.75 → PASS, 최대 5회 반복
- 정체 감지: 연속 2회 점수 개선 < 0.05이면 정체로 판단
- 3회 연속 FAIL → 사용자에게 에스컬레이션
- 5회 도달 → 3가지 선택지 (기준 낮추기, 가이드 후 재시도, 강제 통과)
- Evaluator는 반드시 읽기 전용(plan 모드) — 독립적 판단 보장
- 어떤 도메인이든 "생산 → 평가 → 개선" 반복이 필요하면 적용 가능

## Sources

- [[ai-agency-what-is-agency]]
- [[ai-agency-architecture]]
- [[ai-agency-how-it-works]]

## Related Concepts

- [[multi-agent-systems]]
- [[quality-gate]]
- [[pipeline-routing]]

## Related Pages

- [[ai-agency-build-your-own]]
- [[ai-agency-use-cases]]
