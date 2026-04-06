---
name: compile
description: "raw/ 자료를 wiki/로 컴파일하는 지식 그래프 빌드 파이프라인. 사용자가 '컴파일', '컴파일 해줘', 'compile', '자료 정리해줘', '새 자료 반영해줘', 'raw 처리해줘' 등을 말하거나, raw/에 새 파일을 넣었다고 언급할 때 이 스킬을 사용한다."
---

# Compile

raw/ 자료를 wiki/로 변환하는 전체 파이프라인.

이 스킬의 핵심은 raw 파일을 읽고, source/concept/synthesis 페이지를 생성/갱신하고, 인덱스를 동기화하고, 컴파일 로그를 기록하는 것이다.

## 사전 조건

- `CLAUDE.md`를 읽어서 Required Metadata, Standard Page Template, Change Detection 규칙을 확인한다.
- `wiki/.system/` 인덱스 파일이 존재하지 않으면 먼저 `/bootstrap`을 실행하도록 안내한다.

## 실행 절차

### 1. 상태 파악

`_compile_log.md`를 읽어서 기존 컴파일 기록을 파악한다.

### 2. 변경 감지

`raw/` 디렉토리를 스캔하고, 각 파일의 sha256 해시를 계산한다.

```bash
shasum -a 256 raw/<filename>
```

`_compile_log.md`에 기록된 해시와 비교:
- 해시가 없는 파일 → **신규**
- 해시가 다른 파일 → **변경됨**
- 해시가 같은 파일 → **스킵**

### 3. 처리 범위 결정

신규/변경된 파일 수에 따라 처리 방식을 나눈다:

- **3개 이하** → 한 세션에서 모두 처리
- **4개 이상** → 파일 하나씩 순차 처리 (파일 하나 완료할 때마다 로그 기록)

파일 하나씩 처리하는 이유: 논문 등 대용량 파일이 여러 개 들어오면 컨텍스트 한계에 도달할 수 있다. 파일마다 로그를 기록하면 중간에 세션이 끊겨도 다음 `/compile`에서 이어서 처리할 수 있다.

처리 도중 컨텍스트가 부족해지면:
1. 현재 파일까지 로그를 기록한다
2. 사용자에게 "N개 파일 중 M개 완료. 나머지는 `/compile`을 다시 실행해주세요"라고 안내한다

### 4. 소스 페이지 파일명 결정

source 페이지 파일명은 raw 파일명을 기반으로 kebab-case 영어로 정규화한다:
- 공백 → 하이픈 (`삼성전자 분석.md` → `samsung-analysis.md`)
- 한글 → 영어 번역 또는 음역
- 특수문자/괄호 → 제거
- 대문자 → 소문자
- 이미 같은 이름의 source 페이지가 있으면 뒤에 숫자를 붙인다 (`-2`, `-3`)

### 5. 소스 페이지 생성/갱신

신규/변경된 파일마다:

1. `wiki/sources/`에 source 페이지를 생성하거나 갱신한다.
2. CLAUDE.md의 Required Metadata를 frontmatter에 포함한다:
   - `type: source`
   - `topic`
   - `concepts` (추출한 개념 목록)
   - `aliases` (해당시)
   - `source_file: raw/<filename>`
   - `updated: <오늘 날짜>`
   - `checksum: <sha256>`
3. Standard Page Template을 따른다:
   - Summary, Key Takeaways, Sources, Related Concepts, Related Pages, Open Questions

### 6. 개념 연결 및 생성

1. `wiki/.system/concept-index.md`를 참조하여 기존 concept와 연결한다.
2. aliases까지 확인하여 이름만 다른 같은 개념이 이미 있는지 반드시 체크한다.
3. 반복 등장하는 개념인데 concept 페이지가 없으면 `wiki/concepts/`에 새로 만든다.
4. 새 concept 페이지에도 Required Metadata와 Standard Page Template을 적용한다.

### 7. Synthesis 검토

기존 synthesis 페이지에 영향이 있는지 검토하고, 필요하면 갱신한다.

### 8. 인덱스 갱신

`wiki/.system/` 인덱스 4개를 모두 갱신한다:
- `master-index.md` — 전체 wiki 페이지 목록
- `source-index.md` — raw 파일 → source 페이지 + checksum
- `concept-index.md` — 개념명 → 페이지 경로 + aliases
- `synthesis-index.md` — synthesis 페이지 + 연결 목록

### 9. 로그 기록

`_compile_log.md`에 처리 결과를 테이블 행으로 추가한다:

```
| date | source_file | sha256 | status | derived_pages | concepts_touched | notes |
```

### 10. 결과 보고

무엇을 새로 만들고, 갱신하고, 스킵했는지 요약한다.

## 주의사항

- `[[wiki links]]`를 사용하여 페이지 간 연결을 만든다.
- 출처가 불명확하면 "출처 미확인"으로 명시한다. 지어내지 않는다.
- LLM이 추론한 내용은 추론임을 표시한다.
- 개념 이름은 기존 concept-index.md의 표기를 따른다. 새 이름을 만들기 전에 기존 이름을 확인한다.
