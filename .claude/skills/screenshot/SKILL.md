---
name: screenshot
description: "Capture the terminal window (Ghostty or WezTerm) and display it. Use this skill whenever the user says 'screenshot', 'capture', 'montre-moi l'écran', 'show me the terminal', or when you need to visually inspect the current state of the terminal, tmux statusbar, pane layout, or terminal rendering. Also use it proactively when debugging visual issues like statusbar styling, icon rendering, or color problems."
user_invocable: true
---

# Screenshot

Captures the terminal window (Ghostty or WezTerm) and displays it inline so you can visually inspect the terminal state.

## How it works

The script `~/.local/bin/screenshot.sh` uses python3+Quartz to find the terminal window ID (tries Ghostty first, then WezTerm), then `screencapture -l` to capture just that window (not the full screen). The image is compressed to JPEG quality 65, max 2560px wide — optimized for context window efficiency.

## Steps

1. Run the screenshot script:
```bash
~/.local/bin/screenshot.sh
```

2. Read the output path (default `/tmp/terminal-screenshot.jpg`) with the Read tool to display the image.

3. Describe what you see — especially the statusbar, pane layout, and any visual issues.

## When the script fails

If the script can't find any terminal window (e.g., neither Ghostty nor WezTerm is running), it exits with an error. If python3 doesn't have the Quartz module, install it: `pip3 install pyobjc-framework-Quartz`.
