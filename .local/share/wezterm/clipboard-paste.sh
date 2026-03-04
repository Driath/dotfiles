#!/bin/zsh
# Paste from clipboard: if image → save to file and print path, else print text

DIR="$HOME/.local/share/wezterm/clipboard-images"
mkdir -p "$DIR"

TIMESTAMP=$(date +%s)
PID=$$
FILE="$DIR/clipboard-image-${PID}-${TIMESTAMP}.png"

# Try to save image from clipboard with pngpaste
if /opt/homebrew/bin/pngpaste "$FILE" 2>/dev/null; then
  if [[ -s "$FILE" ]]; then
    printf '%s' "$FILE"
    exit 0
  fi
fi

# Fallback: plain text
rm -f "$FILE"
pbpaste
