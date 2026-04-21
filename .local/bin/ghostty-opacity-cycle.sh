#!/usr/bin/env bash
# Cycle through Ghostty background opacity values
# Usage: ghostty-opacity-cycle.sh up|down

CONFIG_REAL="$HOME/dotfiles/.config/ghostty/config"
DIRECTION="${1:-up}"

OPACITIES=(0.70 0.75 0.80 0.85 0.90 0.95 1.0)
TOTAL=${#OPACITIES[@]}

CURRENT=$(grep '^background-opacity = ' "$CONFIG_REAL" 2>/dev/null | sed 's/^background-opacity = //')

INDEX=0
for i in "${!OPACITIES[@]}"; do
    if [[ "${OPACITIES[$i]}" == "$CURRENT" ]]; then
        INDEX=$i
        break
    fi
done

if [[ "$DIRECTION" == "up" ]]; then
    INDEX=$(( (INDEX + 1) % TOTAL ))
else
    if [[ $INDEX -le 0 ]]; then
        INDEX=$(( TOTAL - 1 ))
    else
        INDEX=$(( INDEX - 1 ))
    fi
fi

NEW_OPACITY="${OPACITIES[$INDEX]}"

python3 -c "
import sys
path, opacity = sys.argv[1], sys.argv[2]
with open(path, 'r') as f:
    lines = f.readlines()
with open(path, 'w') as f:
    for line in lines:
        if line.startswith('background-opacity = '):
            f.write('background-opacity = ' + opacity + '\n')
        else:
            f.write(line)
" "$CONFIG_REAL" "$NEW_OPACITY"

osascript -e 'tell application "System Events" to tell process "Ghostty" to click menu item "Reload Configuration" of menu "Ghostty" of menu bar 1' &>/dev/null
sleep 0.3
tmux display-message -d 3000 "󰂤 Opacity: $NEW_OPACITY  ($((INDEX+1))/$TOTAL)"
