---
name: bootstrap
description: "볼트 초기 셋업을 한 번에 수행하는 1회성 스킬. wiki/가 비어있거나 .system/ 인덱스가 없을 때 사용한다. 사용자가 '부트스트랩', 'bootstrap', '초기 설정', '초기화', '처음부터 셋업', '볼트 초기화' 등을 말할 때 이 스킬을 사용한다."
---

# Bootstrap

볼트를 처음 사용하거나, wiki/가 비어있는 상태에서 한 번에 초기 셋업을 수행한다.

이 스킬은 1회성이다. .system/ 인덱스 생성, _compile_log.md 포맷 초기화, Obsidian 설정 정리, 그리고 raw/에 있는 모든 자료의 초기 컴파일까지 한 번에 처리한다.

## 사전 확인

실행 전에 다음을 확인한다:
- `CLAUDE.md`를 읽어서 Required Metadata, Standard Page Template, Change Detection 규칙을 파악한다.
- `wiki/.system/` 디렉토리에 인덱스 파일이 이미 있는지 확인한다. 있으면 bootstrap이 불필요할 수 있으므로 사용자에게 확인한다.

## 실행 절차

### 1. .system/ 인덱스 생성

`wiki/.system/` 디렉토리에 인덱스 4개를 빈 틀로 생성한다:

- `master-index.md` — 전체 wiki 페이지 목록 (type별 분류)
- `source-index.md` — raw 파일 → source 페이지 + checksum
- `concept-index.md` — 개념명 → 페이지 경로 + aliases
- `synthesis-index.md` — synthesis 페이지 + 연결 목록

### 2. _compile_log.md 포맷 초기화

기존 내용을 테이블 포맷으로 교체한다:

```md
# Compile Log

| date | source_file | sha256 | status | derived_pages | concepts_touched | notes |
|------|-------------|--------|--------|---------------|------------------|-------|
```

### 3. Obsidian 설정 정리

`.obsidian/workspace.json`:
- `lastOpenFiles`에서 실제로 존재하지 않는 파일 경로를 제거한다.

`.obsidian/app.json`:
- `userIgnoreFilters`에서 더 이상 필요 없는 항목을 정리한다.

> **참고:** 그래프 뷰의 색상/화살표 설정(`graph.json`)은 Obsidian UI에서 직접 설정해야 한다. 파일로 수정하면 Obsidian이 덮어쓴다. `docs/vault-system-guide.md`의 8-2 섹션에 설정 방법이 있다.

### 4. 초기 컴파일 실행

raw/의 모든 파일을 신규로 취급하여 컴파일한다. `/compile` 스킬과 동일한 절차를 따른다:

1. 각 raw 파일의 sha256 해시 계산
2. wiki/sources/에 source 페이지 생성
3. 개념 추출 → wiki/concepts/에 concept 페이지 생성
4. .system/ 인덱스 4개 갱신
5. _compile_log.md에 엔트리 추가

## 완료 조건

- `.system/` 인덱스 4개가 존재하고 내용이 채워져 있어야 한다.
- `_compile_log.md`에 raw/ 파일 수만큼 엔트리가 있어야 한다.
- raw/ 파일마다 대응하는 `wiki/sources/` 페이지가 있어야 한다.
- 수행 결과를 요약하여 보고한다.
