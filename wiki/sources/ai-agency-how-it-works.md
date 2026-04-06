---
type: source
topic: ai-agency
concepts:
  - pipeline-routing
  - gan-loop
  - multi-agent-systems
  - frozen-evolvable-boundary
aliases: []
source_file: raw/03-how-it-works.md
updated: 2026-04-06
checksum: 4b59365e88957197e5c71490806782d8eddb6cfa1743c695b777a952f3eb4ed7
---

# AI Agency 동작 방식: 실제 사용 시나리오

## Summary

SaaS 랜딩페이지 제작 시나리오를 통해 전체 파이프라인의 실제 동작을 보여준다. Planner 인터뷰 → Copywriter JSON + Designer spec 병렬 → Builder 코드 → Evaluator 4차원 점수 → GAN Loop → Learner 학습까지의 흐름. 5-Layer Safety 안전장치 상세.

## Key Takeaways

- 에이전트 모델 배정: Planner/Learner → Opus, 나머지 → Sonnet
- Evaluator 4차원 점수: Design 30%, Originality 25%, Completeness 25%, Functionality 20%
- Hard Fail 조건: 카피 원본 변경, AI 슬롭 패턴, 모바일 깨짐, 404 링크
- 5-Layer Safety: Frozen Guard → Canary Check → Contradiction Detector → Rate Limiter → Human Approval
- Builder 절대 규칙: 카피라이터 텍스트 변경 금지, 디자인 토큰 외 임의 값 금지
- Evaluator는 읽기 전용(plan 모드) — "고치면 되니까 PASS" 방지

## Sources

- `raw/03-how-it-works.md`

## Related Concepts

- [[pipeline-routing]]
- [[gan-loop]]
- [[multi-agent-systems]]
- [[frozen-evolvable-boundary]]
- [[quality-gate]]

## Related Pages

- [[ai-agency-architecture]]
- [[ai-agency-self-evolution]]
