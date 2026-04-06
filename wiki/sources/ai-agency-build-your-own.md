---
type: source
topic: ai-agency
concepts:
  - multi-agent-systems
  - pipeline-routing
  - gan-loop
  - self-evolution
  - frozen-evolvable-boundary
  - quality-gate
aliases: []
source_file: raw/07-build-your-own-agency.md
updated: 2026-04-06
checksum: bd882d1b45618b86c294fee1c27616b7810063bc4bad5b5485f49e8338e84ad2
---

# 나만의 에이전시 만들기

## Summary

Claude Code를 "조직 구축 플랫폼"으로 활용하여 커스텀 에이전시를 만드는 실전 가이드. 4-Layer 설계(에이전트+컨텍스트 → 라우팅 → 품질 게이트 → 진화), 6가지 라우팅 패턴(순차, 팬아웃/팬인, GAN Loop, 조건 분기, 가드 체크, 에스컬레이션), 다중 에이전시 "그룹사" 아키텍처를 다룬다.

## Key Takeaways

- 4-Layer 설계: Layer 1(에이전트+컨텍스트) → Layer 2(라우팅) → Layer 3(품질 게이트) → Layer 4(진화)
- 에이전트 설계 7가지 결정: 모델, 권한, 도구, 스킬, 메모리, FROZEN, EVOLVABLE
- 6가지 라우팅 패턴: Sequential, Fan-out/Fan-in, GAN Loop, Conditional, Guard, Escalation
- 통신 방식 3가지: 파일 기반 간접(Agency), P2P SendMessage(Stock Research), 하이브리드
- 다중 에이전시: 여러 에이전시를 MoAI가 순차 호출하여 복합 워크플로우 구성
- SKILL.md가 파이프라인의 "코드" — 에이전트가 아니라 SKILL.md가 흐름을 결정
- 생산자와 평가자를 절대 합치지 말 것 — 독립적 검증이 품질의 핵심

## Sources

- `raw/07-build-your-own-agency.md`

## Related Concepts

- [[multi-agent-systems]]
- [[pipeline-routing]]
- [[gan-loop]]
- [[self-evolution]]
- [[frozen-evolvable-boundary]]
- [[quality-gate]]

## Related Pages

- [[ai-agency-architecture]]
- [[ai-agency-use-cases]]
- [[stock-research-architecture]]
