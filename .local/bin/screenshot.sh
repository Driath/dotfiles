#!/bin/bash
# Screenshot terminal window (Ghostty or WezTerm), optimized for Claude Code context
# Usage: screenshot.sh [output_path]

OUT="${1:-/tmp/terminal-screenshot.jpg}"

# Get terminal window ID (try Ghostty first, then WezTerm)
WID=$(python3 -c "
import Quartz
windows = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID)
for name in ['Ghostty', 'WezTerm']:
    for w in windows:
        if name in str(w.get('kCGWindowOwnerName', '')):
            print(w['kCGWindowNumber'])
            exit()
" 2>/dev/null)

if [ -z "$WID" ]; then
  echo "No terminal window found (tried Ghostty, WezTerm)" >&2
  exit 1
fi

# Capture terminal window directly as JPEG
screencapture -x -o -l "$WID" -t jpg "$OUT" 2>/dev/null

if [ ! -f "$OUT" ]; then
  echo "Screenshot failed" >&2
  exit 1
fi

# Compress: resize to max 2560px wide, quality 65
sips -s formatOptions 65 -Z 2560 "$OUT" >/dev/null 2>&1

SIZE=$(stat -f%z "$OUT" 2>/dev/null)
echo "$OUT ($(( SIZE / 1024 ))KB)"
