---
name: screenshot
description: "Capture the terminal window (Ghostty or WezTerm) and display it. Use this skill whenever the user says 'screenshot', 'capture', 'montre-moi l'écran', 'show me the terminal', or when you need to visually inspect the current state of the terminal, pane layout, or terminal rendering. Also use it proactively when debugging visual issues like icon rendering, or color problems."
user_invocable: true
---

# Screenshot

Captures the terminal window (Ghostty or WezTerm) and displays it inline.

## Steps

1. Run: `~/.local/bin/screenshot.sh`
2. Read the output file with the Read tool (check `SCREENSHOT_OUT` in `~/.local/etc/terminal.conf` for the path).
3. Describe what you see — the pane layout, and any visual issues.
