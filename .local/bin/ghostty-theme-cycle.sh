#!/usr/bin/env bash
# Cycle through Ghostty themes
# Usage: ghostty-theme-cycle.sh next|prev

CONFIG_REAL="$HOME/dotfiles/.config/ghostty/config"
THEMES_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
DIRECTION="${1:-next}"

# Get sorted theme list into array
THEMES=()
while IFS= read -r t; do
    THEMES+=("$t")
done < <(ls "$THEMES_DIR" | sort)
TOTAL=${#THEMES[@]}

# Get current theme from config
CURRENT=$(grep '^theme = ' "$CONFIG_REAL" 2>/dev/null | sed 's/^theme = //')

# Find current index
INDEX=-1
for i in "${!THEMES[@]}"; do
    if [[ "${THEMES[$i]}" == "$CURRENT" ]]; then
        INDEX=$i
        break
    fi
done

# Calculate next index
if [[ "$DIRECTION" == "next" ]]; then
    INDEX=$(( (INDEX + 1) % TOTAL ))
elif [[ "$DIRECTION" == "prev" ]]; then
    if [[ $INDEX -le 0 ]]; then
        INDEX=$(( TOTAL - 1 ))
    else
        INDEX=$(( INDEX - 1 ))
    fi
fi

NEW_THEME="${THEMES[$INDEX]}"

# Update config: replace or add theme line (edit the real file, not symlink)
if grep -q '^theme = ' "$CONFIG_REAL"; then
    python3 -c "
import sys
path = sys.argv[1]
theme = sys.argv[2]
with open(path, 'r') as f:
    lines = f.readlines()
with open(path, 'w') as f:
    for line in lines:
        if line.startswith('theme = '):
            f.write('theme = ' + theme + '\n')
        else:
            f.write(line)
" "$CONFIG_REAL" "$NEW_THEME"
else
    python3 -c "
import sys
path = sys.argv[1]
theme = sys.argv[2]
with open(path, 'r') as f:
    lines = f.readlines()
with open(path, 'w') as f:
    f.write('theme = ' + theme + '\n')
    for line in lines:
        f.write(line)
" "$CONFIG_REAL" "$NEW_THEME"
fi

# Reload Ghostty config via macOS menu, then notify
osascript -e 'tell application "System Events" to tell process "Ghostty" to click menu item "Reload Configuration" of menu "Ghostty" of menu bar 1' &>/dev/null
sleep 0.3
tmux display-message -d 3000 "Ghostty: $NEW_THEME ($((INDEX+1))/$TOTAL)"
