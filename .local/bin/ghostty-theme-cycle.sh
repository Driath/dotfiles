#!/usr/bin/env bash
# Cycle through Ghostty themes
# Usage: ghostty-theme-cycle.sh next|prev

CONFIG_REAL="$HOME/dotfiles/.config/ghostty/config"
THEMES_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
DIRECTION="${1:-next}"

# Curated theme list (dark then light)
THEMES=(
    # Dark
    "dark  ▸ Catppuccin Mocha"
    "dark  ▸ Catppuccin Macchiato"
    "dark  ▸ Catppuccin Frappe"
    "dark  ▸ TokyoNight"
    "dark  ▸ TokyoNight Storm"
    "dark  ▸ TokyoNight Night"
    "dark  ▸ TokyoNight Moon"
    "dark  ▸ Dracula"
    "dark  ▸ Dracula+"
    "dark  ▸ Gruvbox Dark"
    "dark  ▸ Gruvbox Dark Hard"
    "dark  ▸ Gruvbox Material Dark"
    "dark  ▸ Nord"
    "dark  ▸ Builtin Solarized Dark"
    "dark  ▸ Atom One Dark"
    "dark  ▸ Rose Pine"
    "dark  ▸ Rose Pine Moon"
    "dark  ▸ Ayu Mirage"
    "dark  ▸ Ayu"
    "dark  ▸ Everforest Dark Hard"
    "dark  ▸ Kanagawa Wave"
    "dark  ▸ Kanagawa Dragon"
    "dark  ▸ Nightfox"
    "dark  ▸ Nordfox"
    "dark  ▸ Cobalt Neon"
    "dark  ▸ Cobalt2"
    "dark  ▸ Material Ocean"
    "dark  ▸ Material Darker"
    "dark  ▸ Monokai Pro"
    "dark  ▸ Monokai Pro Octagon"
    "dark  ▸ Monokai Pro Ristretto"
    "dark  ▸ Night Owl"
    "dark  ▸ Moonfly"
    "dark  ▸ Mellow"
    "dark  ▸ Vesper"
    "dark  ▸ Horizon"
    "dark  ▸ Snazzy"
    "dark  ▸ GitHub Dark"
    "dark  ▸ GitHub Dark Dimmed"
    "dark  ▸ Solarized Osaka Night"
    "dark  ▸ Zenburn"
    # Light
    "light ▸ Catppuccin Latte"
    "light ▸ TokyoNight Day"
    "light ▸ Gruvbox Light"
    "light ▸ Gruvbox Light Hard"
    "light ▸ Gruvbox Material Light"
    "light ▸ Nord Light"
    "light ▸ Builtin Solarized Light"
    "light ▸ Atom One Light"
    "light ▸ Rose Pine Dawn"
    "light ▸ Ayu Light"
    "light ▸ Everforest Light Med"
    "light ▸ Night Owlish Light"
    "light ▸ GitHub Light Default"
    "light ▸ Monokai Pro Light"
    "light ▸ Horizon Bright"
)
TOTAL=${#THEMES[@]}

# Get current theme from config
CURRENT=$(grep '^theme = ' "$CONFIG_REAL" 2>/dev/null | sed 's/^theme = //')

# Find current index by matching the theme name part
INDEX=-1
for i in "${!THEMES[@]}"; do
    THEME_NAME="${THEMES[$i]##*▸ }"
    if [[ "$THEME_NAME" == "$CURRENT" ]]; then
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

ENTRY="${THEMES[$INDEX]}"
NEW_THEME="${ENTRY##*▸ }"
LABEL="${ENTRY}"

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
tmux display-message -d 3000 "🎨 $LABEL  ($((INDEX+1))/$TOTAL)"
