#!/bin/zsh
# Smart clipboard paste for tmux: image → path, text → text
# Sends the result to the active tmux pane
export PATH="/opt/homebrew/bin:$PATH"

DIR="$HOME/.local/share/wezterm/clipboard-images"
mkdir -p "$DIR"

TIMESTAMP=$(date +%s)
PID=$$
FILE="$DIR/clipboard-image-${PID}-${TIMESTAMP}.png"

# Try to save image from clipboard with pngpaste
if /opt/homebrew/bin/pngpaste "$FILE" 2>/dev/null && [[ -s "$FILE" ]]; then
  tmux send-keys -l "$FILE"
  exit 0
fi

# Fallback: plain text
rm -f "$FILE"
TEXT=$(pbpaste)
[ -n "$TEXT" ] && tmux send-keys -l "$TEXT"
