#!/bin/sh
# Screenshot terminal window, optimized for Claude Code context
# Usage: screenshot.sh [output_path]
OUT="${1:-/tmp/terminal-screenshot.jpg}"

WID=$(~/.local/bin/terminal-window-id.sh)
[ -z "$WID" ] && echo "No terminal window found" >&2 && exit 1

screencapture -x -o -l "$WID" -t jpg "$OUT" 2>/dev/null
[ ! -f "$OUT" ] && echo "Screenshot failed" >&2 && exit 1

sips -s formatOptions 65 -Z 2560 "$OUT" >/dev/null 2>&1
SIZE=$(stat -f%z "$OUT" 2>/dev/null)
echo "$OUT ($(( SIZE / 1024 ))KB)"
