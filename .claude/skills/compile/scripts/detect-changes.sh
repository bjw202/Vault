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

  basename_file=$(basename "$file")
  logged_hash=$(grep "$basename_file" "$COMPILE_LOG" 2>/dev/null | tail -1 | grep -o 'sha256:[a-f0-9]*' | sed 's/sha256://')
  if [ -z "$logged_hash" ]; then
    echo "NEW $file $hash"
  elif [ "$logged_hash" != "$hash" ]; then
    echo "CHANGED $file $hash"
  fi
  # else: 해시 동일 → 스킵 (아무것도 출력 안 함)
done
