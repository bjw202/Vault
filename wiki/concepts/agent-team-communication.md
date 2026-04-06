---
type: concept
topic: stock-research
concepts:
  - multi-agent-systems
  - pipeline-routing
aliases:
  - 에이전트 팀 통신
  - SendMessage
  - P2P 통신
  - agent teams
  - 팀 통신
sources:
  - raw/02-architecture.md
  - raw/07-build-your-own-agency.md
  - raw/STOCK_RESEARCH_ARCHITECTURE.md
updated: 2026-04-06
---

# Agent Team Communication

## Summary

멀티 에이전트 시스템에서 에이전트 간 정보를 교환하는 방식. 파일 기반 간접 통신과 P2P SendMessage 직접 통신이 있으며, 목적에 따라 선택하거나 하이브리드로 조합한다.

## Key Takeaways

- **파일 기반 간접 통신** (Agency 방식):
  - 에이전트 A가 파일 저장 → MoAI가 읽어서 → 에이전트 B 프롬프트에 포함
  - 장점: 단순, 예측 가능, 디버깅 쉬움
  - 단점: 실시간 협업 불가, MoAI가 병목
- **P2P SendMessage** (Stock Research 방식):
  - Agent Teams 기능으로 팀원 간 직접 통신
  - 장점: 실시간 교차 검증, 에이전트 간 시너지
  - 단점: 복잡, 메시지 관리 필요
- **하이브리드** (권장):
  - 단계 간 전달: 파일 기반 / 단계 내 협업: P2P
- Stock Research가 Agent Teams를 선택한 이유: fin이 ind에게 직접 "산업 전체 하락 추세인지 확인해달라" 요청 가능

## Sources

- [[ai-agency-architecture]]
- [[ai-agency-build-your-own]]
- [[stock-research-architecture]]

## Related Concepts

- [[multi-agent-systems]]
- [[pipeline-routing]]
