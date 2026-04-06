---
type: concept
topic: ai-agency
concepts:
  - pipeline-routing
  - gan-loop
  - agent-team-communication
aliases:
  - 멀티 에이전트
  - multi-agent
  - 다중 에이전트
  - agent orchestration
  - 에이전트 오케스트레이션
sources:
  - raw/01-what-is-agency.md
  - raw/02-architecture.md
  - raw/07-build-your-own-agency.md
  - raw/STOCK_RESEARCH_ARCHITECTURE.md
updated: 2026-04-06
---

# Multi-Agent Systems

## Summary

여러 전문화된 AI 에이전트가 역할을 분담하여 하나의 목표를 달성하는 시스템 구조. AI Agency(6개 에이전트)와 Stock Research(7개 에이전트)가 이 패턴의 구현 사례.

## Key Takeaways

- 핵심 원리: 역할 분리 — 한 에이전트에 모든 역할을 맡기면 자기 검증이 불가능
- 에이전트 = 직원, 에이전시 = 부서, SKILL.md = SOP, context/ = 사규
- 모델 배정 전략: 판단(opus) / 실행(sonnet) / 탐색(haiku)
- 권한 분리: 생산자(acceptEdits) vs 평가자(plan, 읽기 전용)
- 통신 방식 선택: 파일 기반 간접(단순/예측 가능) vs P2P SendMessage(실시간 협업)
- 4-Layer 설계: 에이전트+컨텍스트 → 라우팅 → 품질 게이트 → 진화

## Sources

- [[ai-agency-what-is-agency]]
- [[ai-agency-architecture]]
- [[ai-agency-build-your-own]]
- [[stock-research-architecture]]

## Related Concepts

- [[pipeline-routing]]
- [[gan-loop]]
- [[agent-team-communication]]
- [[quality-gate]]

## Related Pages

- [[ai-agency-use-cases]]
- [[ai-agency-summary]]
