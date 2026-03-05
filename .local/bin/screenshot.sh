#!/bin/bash
# Screenshot WezTerm window, optimized for Claude Code context
# Usage: screenshot.sh [output_path]

OUT="${1:-/tmp/wezterm-screenshot.jpg}"

# Get WezTerm window ID
WID=$(python3 -c "
import Quartz
windows = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID)
for w in windows:
    if 'WezTerm' in str(w.get('kCGWindowOwnerName', '')):
        print(w['kCGWindowNumber'])
        break
" 2>/dev/null)

if [ -z "$WID" ]; then
  echo "WezTerm window not found" >&2
  exit 1
fi

# Capture WezTerm window directly as JPEG
screencapture -x -o -l "$WID" -t jpg "$OUT" 2>/dev/null

if [ ! -f "$OUT" ]; then
  echo "Screenshot failed" >&2
  exit 1
fi

# Compress: resize to max 2560px wide, quality 65
sips -s formatOptions 65 -Z 2560 "$OUT" >/dev/null 2>&1

SIZE=$(stat -f%z "$OUT" 2>/dev/null)
echo "$OUT ($(( SIZE / 1024 ))KB)"
