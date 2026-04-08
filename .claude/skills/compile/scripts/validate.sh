#!/bin/bash
# validate.sh — wiki 파일의 언어 규칙 및 구조 검증
# 사용법: ./validate.sh <file.md> [file2.md ...]
# 종료 코드: 0 = 통과, 1 = 위반 발견

FAIL=0

for file in "$@"; do
  if [ ! -f "$file" ]; then
    echo "SKIP: $file (파일 없음)"
    continue
  fi

  name=$(basename "$file")

  # 1. 파일명 kebab-case 영어 확인 (macOS/Linux 호환)
  if echo "$name" | grep -q '[^a-z0-9.\-]'; then
    echo "FAIL: $file — 파일명이 kebab-case 영어가 아님: $name"
    FAIL=1
  fi

  # 2. frontmatter machine 필드에 비ASCII 확인 (한글 포함)
  korean_in_machine=$(sed -n '/^---$/,/^---$/p' "$file" | grep -E '^\s*(topic|concepts|type|sources):' | LC_ALL=C grep '[^[:print:][:space:]]')
  if [ -n "$korean_in_machine" ]; then
    echo "FAIL: $file — frontmatter machine 필드에 비ASCII 문자:"
    echo "  $korean_in_machine"
    FAIL=1
  fi

  # 3. [[wiki links]] 링크 타깃에 비ASCII 확인 (|뒤 표시명은 제외)
  # [[target]] 또는 [[target|display]] 에서 target 부분만 추출
  korean_in_links=$(grep -o '\[\[[^]]*\]\]' "$file" | sed 's/\[\[//;s/\]\]//;s/|.*//' | LC_ALL=C grep '[^[:print:][:space:]]')
  if [ -n "$korean_in_links" ]; then
    echo "FAIL: $file — [[link]] 타깃에 비ASCII 문자:"
    echo "  $korean_in_links"
    FAIL=1
  fi

  # 4. frontmatter 필수 필드 확인
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$file")
  if ! echo "$frontmatter" | grep -q '^type:'; then
    echo "FAIL: $file — frontmatter에 type 필드 없음"
    FAIL=1
  fi

done

if [ $FAIL -eq 0 ]; then
  echo "PASS: 모든 파일 검증 통과"
fi

exit $FAIL
