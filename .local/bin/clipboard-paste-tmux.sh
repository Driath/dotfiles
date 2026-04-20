#!/bin/zsh
# Smart clipboard paste for tmux: image → path, text → text
# Sends the result to the active tmux pane
export PATH="/opt/homebrew/bin:$PATH"

# DIR="$HOME/.local/share/wezterm/clipboard-images"
# mkdir -p "$DIR"
# TIMESTAMP=$(date +%s)
# PID=$$
# FILE="$DIR/clipboard-image-${PID}-${TIMESTAMP}.png"
# if /opt/homebrew/bin/pngpaste "$FILE" 2>/dev/null && [[ -s "$FILE" ]]; then
#   tmux send-keys -l "$FILE"
#   exit 0
# fi
# rm -f "$FILE"
TEXT=$(pbpaste)
if [[ -z "$TEXT" ]]; then
  echo "clipboard-paste: clipboard is empty or not text" >&2
  exit 1
fi
# load-buffer via stdin évite la limite "command too long" de send-keys -l
# sur les gros clipboards (> quelques Ko)
printf '%s' "$TEXT" | tmux load-buffer -b clipboard-paste -
tmux paste-buffer -b clipboard-paste -d
