#!/bin/sh
# Captures just the tmux statusbar (bottom of terminal window)
. ~/.local/etc/terminal.conf

OUT="${1:-$STATUSBAR_OUT}"
WID=$(~/.local/bin/terminal-window-id.sh)
[ -z "$WID" ] && echo "No terminal window found" >&2 && exit 1

TMP="/tmp/statusbar-full.png"
screencapture -x -o -l "$WID" -t png "$TMP" 2>/dev/null
H=$(sips -g pixelHeight "$TMP" 2>/dev/null | grep pixelHeight | awk '{print $2}')
W=$(sips -g pixelWidth "$TMP" 2>/dev/null | grep pixelWidth | awk '{print $2}')
OFFSET=$((H - STATUSBAR_HEIGHT))
sips -c "$STATUSBAR_HEIGHT" "$W" --cropOffset "$OFFSET" 0 "$TMP" --out "$OUT" >/dev/null 2>&1
rm "$TMP" 2>/dev/null
echo "$OUT ($(du -k "$OUT" | cut -f1)KB)"
