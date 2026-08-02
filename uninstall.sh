#!/bin/bash
set -e

echo "Uninstalling dotfiles..."

# Starship
rm -f "$HOME/.config/starship.toml"
echo "✓ Starship"

# WezTerm
rm -f "$HOME/.config/wezterm/wezterm.lua"
echo "✓ WezTerm"

# Screenshot tool
rm -f "$HOME/.local/bin/screenshot.sh"
echo "✓ Screenshot tool"

# Clipboard paste script
rm -f "$HOME/.local/share/wezterm/clipboard-paste.sh"
echo "✓ Clipboard paste"

# Claude Code skills
for skill in "$HOME/.claude/skills"/screenshot "$HOME/.claude/skills"/statusbar; do
  [ -L "$skill" ] && rm -f "$skill"
done
echo "✓ Claude Code skills"

# Claude Code hook
rm -f "$HOME/.local/share/claude/notify-done.sh"
if [ -f "$HOME/.claude/settings.json" ]; then
  python3 -c "
import json
path = '$HOME/.claude/settings.json'
with open(path) as f:
    s = json.load(f)
if 'Stop' in s.get('hooks', {}):
    s['hooks']['Stop'] = [
        h for h in s['hooks']['Stop']
        if not any(hook.get('command', '').endswith('notify-done.sh') for hook in h.get('hooks', []))
    ]
    if not s['hooks']['Stop']:
        del s['hooks']['Stop']
    if not s['hooks']:
        del s['hooks']
    with open(path, 'w') as f:
        json.dump(s, f, indent=2)
    print('✓ Claude hook removed')
"
fi
echo "✓ Claude Code notifications"

echo "Done."
