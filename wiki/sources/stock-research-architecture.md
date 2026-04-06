---
type: source
topic: stock-research
concepts:
  - multi-agent-systems
  - pipeline-routing
  - quality-gate
  - agent-team-communication
aliases: []
source_file: raw/STOCK_RESEARCH_ARCHITECTURE.md
updated: 2026-04-06
checksum: 63189ae3df5f74a865d4eb10ee530911d65f3c91a6a9f728e1d1017ee128ae47
---

# Stock Research 멀티 에이전트 아키텍처

## Summary

7명의 AI 에이전트(6명 병렬 분석 + 1명 독립 검증)로 구성된 투자 리서치 시스템. 팬아웃/팬인 + 2-Phase 아키텍처를 사용하며, Agent Teams의 P2P SendMessage로 에이전트 간 실시간 교차 분석을 수행한다. Agency의 파일 기반 통신과 대비되는 설계.

## Key Takeaways

- 7명 에이전트: biz(비즈니스), fin(재무), ind(산업), sent(센티먼트), risk(리스크), quant(퀀트), devil(독립 반박)
- Phase A: 6명 병렬 분석, Phase B: devil이 모든 결과를 읽고 독립 검증
- 에이전트 팀 선택 이유: P2P SendMessage로 팀원 간 직접 통신 — fin이 ind에게 직접 확인 요청 가능
- 서브 에이전트 방식과의 차이: 서브 에이전트는 팀원 간 통신 불가, 메인 거쳐야 함
- devil은 다른 분석가와 통신하지 않음 — 독립성이 핵심
- 데이터 전달: 파일 기반(산출물) + 메시지 기반(실시간 발견 공유) 하이브리드
- 스킬 vs 에이전트 vs 스크립트 구분: 스킬=업무 매뉴얼, 에이전트=직원, 스크립트=도구

## Sources

- `raw/STOCK_RESEARCH_ARCHITECTURE.md`

## Related Concepts

- [[multi-agent-systems]]
- [[pipeline-routing]]
- [[quality-gate]]
- [[agent-team-communication]]

## Related Pages

- [[ai-agency-architecture]]
- [[ai-agency-build-your-own]]

## Open Questions

- Stock Research에는 Learner/자기진화 메커니즘이 아직 없음 — Agency 패턴 적용 여부 미결정
