---
name: graph-lint
description: "wiki/ 지식 그래프의 품질을 점검하고 문제를 수정하는 린트 스킬. 사용자가 'lint', '린트', 'audit', '감사', '점검', '그래프 정리', '구조 점검', '깨진 링크 확인', '인덱스 동기화' 등을 말할 때 이 스킬을 사용한다."
---

# Graph Lint

wiki/ 지식 그래프의 구조적 품질을 점검하고, 발견된 문제를 직접 수정한다.

컴파일을 여러 번 하다 보면 깨진 링크, 고아 문서, 중복 개념, 인덱스 불일치 등이 쌓일 수 있다. 이 스킬은 그런 문제를 체계적으로 찾아서 고친다.

## 점검 항목

### 1. 컴파일 누락

- `raw/`에 파일이 있는데 `_compile_log.md`에 해당 엔트리가 없는 경우
- 이 경우 사용자에게 `/compile` 실행을 권한다

### 2. 문서 품질

- source 페이지에 provenance(출처 정보) 누락
- Required Metadata 필드 빠진 페이지 (type, topic, concepts, aliases, source_file/sources, updated, checksum)
- Standard Page Template 필수 섹션 누락 (Key Takeaways, Sources)

### 3. 개념 그래프 무결성

- **중복 concept** — `aliases`를 기준으로 이름만 다른 같은 개념 탐지
- **고아 concept** — 어떤 source나 synthesis에서도 참조하지 않는 concept 페이지
- **고아 source** — 어떤 concept에도 연결 안 된 source 페이지
- **깨진 링크** — `[[wiki links]]`가 존재하지 않는 페이지를 가리키는 경우

### 4. 인덱스 동기화

- `.system/` 인덱스 4개가 실제 wiki/ 파일과 일치하는지 확인
- 인덱스에는 있는데 파일이 없는 경우 (유령 엔트리)
- 파일이 있는데 인덱스에 없는 경우 (누락 엔트리)

### 5. Obsidian 설정 정합성

- `.obsidian/workspace.json`의 `lastOpenFiles`에 존재하지 않는 경로가 있는지 확인

## 실행 방식

### 1단계: 전체 스캔

위 점검 항목을 전부 확인한다. Glob과 Grep 도구를 활용하여 wiki/ 전체를 스캔한다.

### 2단계: 보고

발견된 문제를 심각도별로 정리하여 보고한다:
- **CRITICAL** — 데이터 손실 위험 (깨진 링크로 인한 정보 단절 등)
- **HIGH** — 구조적 불일치 (인덱스 동기화 실패, 컴파일 누락 등)
- **MEDIUM** — 품질 저하 (메타데이터 누락, 고아 문서 등)
- **LOW** — 개선 권장 (Obsidian 설정 등)

### 3단계: 자동 수정

확실하게 고칠 수 있는 것은 바로 수정한다:
- 인덱스 재생성/동기화
- 중복 concept 병합 (aliases 보존, 링크 리다이렉트)
- workspace.json 유령 참조 제거
- 빠진 메타데이터 필드 추가 (값을 알 수 있는 경우)

### 4단계: 사용자 판단 요청

자동 수정이 애매한 것은 선택지를 제시한다:
- 고아 문서를 삭제할지 연결할지
- 깨진 링크를 제거할지 대상 페이지를 새로 만들지

### 5단계: 결과 요약

수정한 것과 남은 문제를 요약한다.
