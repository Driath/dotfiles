#!/bin/sh
# Screenshot terminal window, optimized for Claude Code context
. ~/.local/etc/terminal.conf

OUT="${1:-$SCREENSHOT_OUT}"
WID=$(~/.local/bin/terminal-window-id.sh)
[ -z "$WID" ] && echo "No terminal window found" >&2 && exit 1

screencapture -x -o -l "$WID" -t jpg "$OUT" 2>/dev/null
[ ! -f "$OUT" ] && echo "Screenshot failed" >&2 && exit 1

sips -s formatOptions "$SCREENSHOT_QUALITY" -Z "$SCREENSHOT_MAX_WIDTH" "$OUT" >/dev/null 2>&1
SIZE=$(stat -f%z "$OUT" 2>/dev/null)
echo "$OUT ($(( SIZE / 1024 ))KB)"
