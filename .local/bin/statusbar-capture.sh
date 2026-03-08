#!/bin/sh
# Captures just the tmux statusbar (bottom 80px of terminal window)
OUT="${1:-/tmp/statusbar.png}"
WID=$(~/.local/bin/terminal-window-id.sh)
[ -z "$WID" ] && echo "No terminal window found" >&2 && exit 1

screencapture -x -o -l "$WID" -t png /tmp/statusbar-full.png 2>/dev/null
H=$(sips -g pixelHeight /tmp/statusbar-full.png 2>/dev/null | grep pixelHeight | awk '{print $2}')
W=$(sips -g pixelWidth /tmp/statusbar-full.png 2>/dev/null | grep pixelWidth | awk '{print $2}')
OFFSET=$((H - 80))
sips -c 80 "$W" --cropOffset "$OFFSET" 0 /tmp/statusbar-full.png --out "$OUT" >/dev/null 2>&1
rm /tmp/statusbar-full.png 2>/dev/null
echo "$OUT ($(du -k "$OUT" | cut -f1)KB)"
