#!/bin/bash
# detect-changes.sh — raw/ 파일의 신규/변경 감지
# 사용법: ./detect-changes.sh
# 출력: 처리 필요한 파일 목록 (한 줄에 하나씩)
#   NEW raw/filename.md sha256hash
#   CHANGED raw/filename.md sha256hash
# 아무것도 출력하지 않으면 변경 없음

COMPILE_LOG="_compile_log.md"

# raw/assets/ 제외, .md 파일만
for file in raw/*.md; do
  [ -f "$file" ] || continue

  hash=$(shasum -a 256 "$file" | awk '{print $1}')

  if grep -q "$hash" "$COMPILE_LOG" 2>/dev/null; then
    continue  # 해시 동일 → 스킵
  elif grep -q "$(basename "$file")" "$COMPILE_LOG" 2>/dev/null; then
    echo "CHANGED $file $hash"
  else
    echo "NEW $file $hash"
  fi
done
