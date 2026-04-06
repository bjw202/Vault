---
type: source
topic: ai-agency
concepts:
  - pipeline-routing
  - multi-agent-systems
  - gan-loop
  - brand-context-management
aliases: []
source_file: raw/02-architecture.md
updated: 2026-04-06
checksum: 65b5e31710454c39efe34b8799a44e8c50c51e3e08a77b2b8030575c7663530d
---

# AI Agency 아키텍처 상세

## Summary

6단계 파이프라인(Planner→Copywriter&Designer→Builder↔Evaluator→Learner)의 상세 구조. 라우팅 주체는 MoAI 오케스트레이터이며, 에이전트 간 통신은 파일 기반 간접 통신을 사용한다. SKILL.md가 사실상 파이프라인의 "코드" 역할을 한다.

## Key Takeaways

- 라우팅 3계층: 서브커맨드 라우팅 → 파이프라인 순서 제어 → 조건부 라우팅
- 에이전트 간 직접 통신 없음 — MoAI가 파일을 읽어서 다음 에이전트 프롬프트에 포함
- Agency(파일 기반 간접) vs Stock Research(P2P SendMessage) 통신 방식 대비
- SKILL.md = 선언적 파이프라인 스크립트 — 에이전트가 "누구"이고 스킬이 "어떻게"
- Planner/Learner는 Opus, 나머지 4개는 Sonnet — 비용 최적화
- Evaluator는 plan 모드(읽기 전용) — 독립적 판단 보장
- GAN Loop: 점수 ≥ 0.75 → PASS, 최대 5회 반복, 정체 감지 메커니즘
- `.agency/context/` 5개 파일이 모든 에이전트 행동을 규정

## Sources

- `raw/02-architecture.md`

## Related Concepts

- [[pipeline-routing]]
- [[multi-agent-systems]]
- [[gan-loop]]
- [[brand-context-management]]
- [[frozen-evolvable-boundary]]

## Related Pages

- [[ai-agency-what-is-agency]]
- [[ai-agency-how-it-works]]
- [[stock-research-architecture]]

## Open Questions

- 병렬 실행(Copywriter + Designer) 시 출력 품질 간 불일치 처리 방법 미명시
