---
name: statusbar
description: "Capture and display only the tmux statusbar from the terminal (Ghostty or WezTerm). Use this skill when the user says 'statusbar', 'montre la statusbar', 'show me the bar', or when you need to inspect statusbar styling, plugin output, icon rendering, colors, or layout without seeing the full terminal. Prefer this over a full screenshot when the focus is specifically on the statusbar."
user_invocable: true
---

# Statusbar

Captures just the tmux statusbar (bottom of terminal window).

## Steps

1. Run: `~/.local/bin/statusbar-capture.sh`
2. Read the output file with the Read tool (check `STATUSBAR_OUT` in `~/.local/etc/terminal.conf` for the path).
3. Check: icons, colors, dim/active states, layout left/right.
