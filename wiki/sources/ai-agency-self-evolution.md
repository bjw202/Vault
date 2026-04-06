---
type: source
topic: ai-agency
concepts:
  - self-evolution
  - frozen-evolvable-boundary
aliases: []
source_file: raw/04-self-evolution.md
updated: 2026-04-06
checksum: 12c2e3900cd26d21b6cd44716396cb46f3c4029c107eb87f44d5f5d8831a215b
---

# AI Agency 자기진화 시스템 상세

## Summary

Learner가 Evaluator 피드백에서 패턴을 감지하고, 관찰→휴리스틱→규칙→고신뢰 단계를 거쳐 에이전트의 EVOLVABLE Zone을 수정 제안하는 메커니즘. 신뢰도 감쇄(90일 반감기), Anti-Pattern 즉시 차단, FROZEN/EVOLVABLE 경계 등의 안전장치를 포함.

## Key Takeaways

- 학습 단계: 1회(관찰) → 3회(휴리스틱) → 5회(규칙 후보) → 10회+(고신뢰)
- 졸업 조건: 5회 이상 관찰 + 신뢰도 80% + 일관성 80% + 모순 없음 + 30일 이내
- 신뢰도 감쇄: `weight = base × 0.5^(경과일/90)` — 90일 반감기
- 0.30 미만 → 폐기 후보
- Anti-Pattern: 1회라도 치명적이면 즉시 FROZEN 등록, Learner도 삭제 불가
- FROZEN Zone: 정체성, 안전 규칙, 윤리 경계 — 절대 변경 불가
- EVOLVABLE Zone: 스타일 가이드, 출력 패턴, 프레임워크 선호 — 학습으로 개선 가능
- Fork Manifest: MoAI 에이전트에서 포크된 이력 추적, generation으로 분화 정도 관리

## Sources

- `raw/04-self-evolution.md`

## Related Concepts

- [[self-evolution]]
- [[frozen-evolvable-boundary]]

## Related Pages

- [[ai-agency-how-it-works]]
- [[ai-agency-use-cases]]
