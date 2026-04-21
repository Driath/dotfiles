#!/usr/bin/env bash
# Cycle through Ghostty fonts (updates first font-family line)
# Usage: ghostty-font-cycle.sh next|prev

CONFIG_REAL="$HOME/dotfiles/.config/ghostty/config"
STATE_FILE="$HOME/.local/state/ghostty/font-index"
DIRECTION="${1:-next}"

FONTS=(
    "GeistMono Nerd Font"
    "Hack Nerd Font"
    "FiraCode Nerd Font"
    "JetBrainsMono Nerd Font"
    "CommitMono Nerd Font"
    "MesloLGS Nerd Font"
    "SauceCodePro Nerd Font"
    "Inconsolata Nerd Font"
    "JetBrains Mono"
    "BlexMono Nerd Font"
    "VictorMono Nerd Font"
    "Iosevka Nerd Font"
    "Maple Mono NF"
)
TOTAL=${#FONTS[@]}

mkdir -p "$(dirname "$STATE_FILE")"
INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo "0")

if [[ "$DIRECTION" == "next" ]]; then
    INDEX=$(( (INDEX + 1) % TOTAL ))
else
    if [[ $INDEX -le 0 ]]; then
        INDEX=$(( TOTAL - 1 ))
    else
        INDEX=$(( INDEX - 1 ))
    fi
fi

echo "$INDEX" > "$STATE_FILE"
NEW_FONT="${FONTS[$INDEX]}"

python3 -c "
import sys
path, font = sys.argv[1], sys.argv[2]
with open(path, 'r') as f:
    lines = f.readlines()
found = False
with open(path, 'w') as f:
    for line in lines:
        if not found and line.startswith('font-family = '):
            f.write('font-family = ' + font + '\n')
            found = True
        else:
            f.write(line)
" "$CONFIG_REAL" "$NEW_FONT"

osascript -e 'tell application "System Events" to tell process "Ghostty" to click menu item "Reload Configuration" of menu "Ghostty" of menu bar 1' &>/dev/null
sleep 0.3
tmux display-message -d 3000 " Font: $NEW_FONT  ($((INDEX+1))/$TOTAL)"
