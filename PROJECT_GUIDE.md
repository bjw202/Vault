# Personal Knowledge RAG System Guide

## 목적

이 저장소는 개인용 지식 축적, 검색, 질의응답, 재합성을 위한 LLM 기반 RAG 시스템이다.

목표는 단순히 문서를 쌓는 것이 아니라, 다음 루프를 지속적으로 운영하는 것이다.

1. 자료 수집
2. 자료 정리 및 구조화
3. 질문에 대한 합성 답변 생성
4. 유용한 결과를 다시 지식베이스에 편입

즉, 일회성 메모 저장소가 아니라 시간이 갈수록 더 잘 답하는 지식 시스템을 만드는 것이 목적이다.

## 핵심 원칙

- `raw/`는 원본 보관소다.
- `wiki/`는 정제된 지식 레이어다.
- `output/`은 사용자 요청에 대한 결과물 저장소다.
- `_compile_log.md`는 컴파일 및 갱신 이력을 기록하는 매니페스트다.
- 지식의 핵심 단위는 `토픽`보다 `개념`이다.
- 문서는 서로 링크되어야 하며, 고립된 노트를 최소화해야 한다.
- 출처와 추론은 분리해서 기록해야 한다.

## 전체 아키텍처

### 1. Raw Layer

경로:

- `raw/`

역할:

- 원문 보존
- 웹 클리핑 결과 저장
- 논문, 기사, 레포, 데이터셋 설명, 이미지 메모 등 입력 자료 저장

특징:

- 이 레이어는 가능한 한 원형을 유지한다.
- 직접 질의응답의 최종 근거가 되지만, 평소 탐색의 주 레이어는 아니다.

### 2. Knowledge Layer

경로:

- `wiki/sources/`
- `wiki/concepts/`
- `wiki/syntheses/`

역할:

- raw 자료를 사람이 읽고 LLM이 재사용하기 쉬운 구조로 변환
- 검색과 추론의 기준층 형성

세부 구성:

- `sources`
  - raw 문서 1개 또는 밀접한 묶음 1개에 대응하는 컴파일 노트
  - 핵심 요약, 주요 주장, 관련 개념, 출처를 기록
- `concepts`
  - 여러 source에 반복 등장하는 개념, 방법론, 엔티티, 패턴을 정리
  - 실제 RAG 검색과 추론의 중심 허브
- `syntheses`
  - 여러 source와 concept를 엮어서 만든 종합 분석
  - 비교, 브리핑, 장단점 분석, 전략 문서 등이 여기에 해당

### 3. Output Layer

경로:

- `output/`

역할:

- 사용자 요청에 대한 결과물 저장
- 보고서, Q&A 문서, 슬라이드, 시각화 설명 등 생성 산출물 보관

원칙:

- 일회성 결과는 `output/`에 둔다.
- 반복 사용 가치가 생기면 `wiki/syntheses/` 또는 `wiki/concepts/`로 승격한다.

### 4. System Layer

경로:

- `wiki/.system/`

역할:

- 숨김 인덱스와 유지보수 정보 저장
- Obsidian 탐색을 덜 어지럽히면서 기계 친화적인 유지보수 가능

대표 파일:

- `wiki/.system/master-index.md`
- `wiki/.system/source-index.md`
- `wiki/.system/concept-index.md`
- `wiki/.system/synthesis-index.md`

## 왜 Topic보다 Concept가 중요한가

토픽은 보관과 대분류에는 유용하지만, 시간이 지나면 쉽게 흔들린다.

예를 들어:

- `ai-agency`
- `stock-research`

는 다른 토픽처럼 보여도 실제로는 다음 개념을 공유할 수 있다.

- multi-agent orchestration
- research workflow
- report generation
- evaluator loop

그래서 이 시스템은 토픽 폴더만 믿지 않는다. 반복되는 개념은 `wiki/concepts/`에 따로 정리하고, source와 synthesis가 그 개념에 연결되도록 설계한다.

## 문서 단위 설계

### Source 문서

권장 메타데이터:

- `type: source`
- `topic`
- `concepts`
- `source_file`
- `source_url`
- `updated`

역할:

- 원문을 구조화된 지식으로 바꾸는 첫 단계
- 출처 보존
- 개념 추출

### Concept 문서

권장 메타데이터:

- `type: concept`
- `topic`
- `concepts`
- `sources`
- `aliases`
- `updated`

역할:

- 반복 개념의 허브
- 검색과 질의응답의 중심점
- 토픽 간 연결 매개

### Synthesis 문서

권장 메타데이터:

- `type: synthesis`
- `topic`
- `concepts`
- `sources`
- `question`
- `updated`

역할:

- 여러 자료를 묶어 결론 생성
- 재사용 가능한 분석 축적

## 표준 문서 템플릿

기본적으로 모든 주요 문서는 다음 구조를 권장한다.

```md
# Title

## Summary

## Key Takeaways

## Sources

## Related Concepts

## Related Pages

## Open Questions
```

운영 원칙:

- `Key Takeaways`는 필수
- `Sources`는 비자명 문서에서 필수
- `Related Concepts`에는 개념 링크를 넣는다
- `Open Questions`는 실제로 없을 때만 생략한다

## 컴파일 워크플로우

사용자가 `compile`을 요청하면 다음 순서로 처리한다.

1. `_compile_log.md`를 읽는다.
2. `raw/`를 스캔한다.
3. 신규 파일과 변경 파일을 판별한다.
4. 파일별로 `wiki/sources/`에 source 문서를 생성 또는 갱신한다.
5. 기존 concept와 연결한다.
6. 반복 개념이 새로 보이면 `wiki/concepts/`에 concept 문서를 만든다.
7. 더 넓은 결론이 변하면 `wiki/syntheses/`를 갱신한다.
8. `wiki/.system/` 인덱스를 갱신한다.
9. `_compile_log.md`에 처리 결과를 기록한다.

중요한 점:

- compile은 단순 요약이 아니다.
- 정리, 분류, 링크, 중복 축소, 개념 승격까지 포함한다.

## 증분 업데이트 전략

자료가 계속 늘어난다고 해서 매번 전체를 다시 만드는 방식은 비효율적이다.

기본 전략:

- 신규 raw 파일만 우선 처리
- 내용이 크게 바뀐 파일만 재컴파일
- 변화가 없으면 기존 결과 유지

장기적으로 `_compile_log.md`에는 최소한 아래가 기록되는 것이 좋다.

- 날짜
- source filename
- 처리 상태
- 파생 문서
- 영향 받은 개념
- 메모

## 개념 진화 전략

지식베이스가 성장하면 개념 체계도 바뀌어야 한다.

반드시 발생하는 변화:

- 같은 개념이 다른 이름으로 중복 생성됨
- 하나의 개념이 너무 넓어짐
- 예전엔 중요하지 않던 개념이 반복 등장함
- 기존 토픽 분류보다 개념 분류가 더 유용해짐

운영 규칙:

- 새 concept를 만들기 전에 기존 concept와 중복 여부를 확인한다.
- 반복되는 아이디어는 concept로 승격한다.
- 너무 넓은 concept는 split한다.
- 중복 concept는 merge하고 alias를 남긴다.
- 개념 개편 시 관련 source와 synthesis 링크도 함께 정리한다.

## 질의응답 전략

질문이 들어오면 다음 우선순위를 따른다.

1. `wiki/.system/` 인덱스 확인
2. 관련 concept 문서 확인
3. 관련 source 문서 확인
4. 필요하면 synthesis 문서 확인
5. 그 위에서 답변 생성

좋은 답변의 원칙:

- vault 안의 지식을 우선 사용
- 출처 기반으로 말하기
- 추론은 추론으로 표시
- 반복될 만한 답변은 `output/` 또는 `wiki/syntheses/`에 남기기

## Audit / Lint 전략

정기적으로 다음을 점검한다.

- `raw/`에는 있는데 `_compile_log.md`에 없는 파일
- provenance가 약한 source 문서
- 링크가 거의 없는 concept 문서
- 중복 개념
- 깨진 내부 링크
- 고립된 source 문서
- 근거가 약한 synthesis 문서
- 승격해야 하는 output
- 실제 구조와 맞지 않는 hidden index

가능하면 문제를 나열만 하지 말고 직접 수정한다.

## 활용 방법

### 1. 새 자료를 넣을 때

- 원문을 `raw/`에 넣는다.
- 필요하면 파일명과 출처가 드러나도록 정리한다.
- 이후 `compile`을 실행한다.

### 2. 특정 주제를 이해하고 싶을 때

- concept 문서부터 읽는다.
- 필요하면 연결된 source 문서로 내려가 근거를 본다.
- 기존 synthesis가 있으면 재사용한다.

### 3. 질문에 대한 결과를 남기고 싶을 때

- `output/`에 결과를 저장한다.
- 반복 가치가 확인되면 wiki로 승격한다.

### 4. 구조가 어지러워졌을 때

- audit 또는 lint를 수행한다.
- concept 중복, broken link, orphan 문서를 정리한다.

## Obsidian에서의 사용 전략

- 일상 탐색은 `wiki/sources/`, `wiki/concepts/`, `wiki/syntheses/` 위주로 한다.
- 유지보수 인덱스는 `wiki/.system/`에 둔다.
- 루트 운영 문서나 시스템 문서는 필요하면 `Excluded files`로 그래프에서 제외한다.
- 그래프는 탐색 보조 도구이지, 전체 구조의 진실 그 자체는 아니다.

## 운영상 기대 효과

이 구조를 유지하면 다음이 가능해진다.

- 자료가 늘어나도 신규/변경 중심으로 증분 처리
- 서로 다른 주제 간의 공통 개념 연결
- 반복 질문에 대한 누적 학습
- 출처 보존과 추론 구분
- Obsidian에서 사람이 읽기 좋은 형태와 LLM이 재사용하기 좋은 형태의 균형 유지

## 한 줄 요약

이 프로젝트는 raw 자료를 source로 컴파일하고, source를 concept로 연결하고, concept를 synthesis와 output으로 확장하는 개인용 지식 RAG 운영체계다.
