---
name: graph-lint
description: "wiki/ 지식 그래프의 품질을 점검하고 문제를 수정하는 린트 스킬. 사용자가 'lint', '린트', 'audit', '감사', '점검', '그래프 정리', '구조 점검', '깨진 링크 확인', '인덱스 동기화' 등을 말할 때 이 스킬을 사용한다."
---

# Graph Lint

wiki/ 지식 그래프의 구조적 품질을 점검하고, 발견된 문제를 직접 수정한다.

## 기본 원칙

- **깨진 링크는 보고만 하고 끝내지 않는다.** compile 중 누락으로 발생한 구조적 결함이므로 기본 동작은 "스텁 concept 파일 자동 생성"이다.
- 삭제는 사용자가 명시적으로 요청할 때만 한다.
- 깨진 링크가 0개가 아니면 graph-lint는 완료된 것이 아니다.

## 점검 항목

### 1. 컴파일 누락

- `raw/`에 파일이 있는데 `_compile_log.md`에 엔트리가 없는 경우
- 사용자에게 `/compile` 실행을 권한다

### 2. 문서 품질

- source 페이지에 provenance(출처 정보) 누락
- frontmatter 필수 필드 빠진 페이지 (type, topic, concepts)

### 3. 개념 그래프 무결성

- **중복 concept** — aliases 기준으로 이름만 다른 같은 개념
- **고아 concept** — 어떤 source/synthesis에서도 참조하지 않는 concept
- **고아 source** — 어떤 concept에도 연결 안 된 source
- **원본 없는 source** — source_file이 가리키는 raw 파일이 존재하지 않는 경우
- **깨진 링크** — `[[wiki links]]`가 존재하지 않는 페이지를 가리키는 경우

### 4. 인덱스 동기화

- `wiki/index.md`가 실제 wiki/ 파일과 일치하는지 확인
- 인덱스에 있는데 파일이 없는 경우 (유령 엔트리)
- 파일이 있는데 인덱스에 없는 경우 (누락 엔트리)

## 실행 방식

### 1단계: 전체 스캔

위 점검 항목을 전부 확인한다.

### 2단계: 보고

발견된 문제를 심각도별로 정리 (CRITICAL / HIGH / MEDIUM / LOW).

### 3단계: 자동 수정

확실하게 고칠 수 있는 것은 바로 수정한다. **묻지 않는다.**

- 인덱스 재생성/동기화
- 중복 concept 병합 (aliases 보존)
- 빠진 frontmatter 필드 추가
- **깨진 concept 링크 → 스텁 concept 파일 자동 생성**
  - `wiki/concepts/<link-target>.md`를 즉시 생성
  - frontmatter 예시:
    ```yaml
    ---
    type: concept
    topic:
      - <참조한 source의 topic 재사용>
    aliases:
      - <추론 가능한 한글/영문 이름>
    ---
    ```
  - 본문: `<!-- TODO: graph-lint가 생성한 스텁. 내용 보강 필요 -->` + 한 줄 정의
  - 생성 후 사용자에게 "N개의 스텁 concept를 만들었다. 나중에 `/compile` 또는 수동 보강 필요" 보고

### 4단계: 사용자 판단 요청 (진짜 애매한 것만)

- 고아 문서를 삭제할지 유지할지
- `source_file`이 가리키는 raw 파일이 없는 source를 삭제할지
- 명백히 오타로 보이는 링크는 어떻게 할지 (삭제 vs 리네이밍)

### 5단계: 결과 요약

수정한 것과 남은 문제를 요약한다. **깨진 링크가 0개가 아니면 완료로 판정하지 않는다.**