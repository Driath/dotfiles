---
name: statusbar
description: "Capture and display only the tmux statusbar from WezTerm. Use this skill when the user says 'statusbar', 'montre la statusbar', 'show me the bar', or when you need to inspect statusbar styling, plugin output, icon rendering, colors, or layout without seeing the full terminal. Prefer this over a full screenshot when the focus is specifically on the statusbar."
user_invocable: true
---

# Statusbar

Captures just the bottom statusbar of WezTerm (tmux status line) and displays it for visual inspection.

## How it works

Captures the WezTerm window, then crops the bottom 80px which contains the tmux statusbar. This gives a high-resolution view of the bar — much easier to read than a full terminal screenshot.

## Steps

Run this as a single bash command:

```bash
WID=$(python3 -c "
import Quartz
windows = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID)
for w in windows:
    if 'WezTerm' in str(w.get('kCGWindowOwnerName', '')):
        print(w['kCGWindowNumber'])
        break
" 2>/dev/null) && \
screencapture -x -o -l "$WID" -t png /tmp/wez-statusbar-full.png 2>/dev/null && \
H=$(sips -g pixelHeight /tmp/wez-statusbar-full.png 2>/dev/null | grep pixelHeight | awk '{print $2}') && \
W=$(sips -g pixelWidth /tmp/wez-statusbar-full.png 2>/dev/null | grep pixelWidth | awk '{print $2}') && \
OFFSET=$((H - 80)) && \
sips -c 80 "$W" --cropOffset "$OFFSET" 0 /tmp/wez-statusbar-full.png --out /tmp/statusbar.png >/dev/null 2>&1 && \
rm /tmp/wez-statusbar-full.png 2>/dev/null && \
echo "/tmp/statusbar.png ($(du -k /tmp/statusbar.png | cut -f1)KB)"
```

Then read `/tmp/statusbar.png` with the Read tool to display the image.

## What to look for

- **Left side**: session icon, name, index, separator, window list with icons
- **Right side**: online status, battery, CPU, RAM, clock
- **Colors**: should match the design system (@color-* variables)
- **Icons**: nerd font icons should render correctly, not as letters or boxes
- **Dim**: inactive windows should be dimmed, active should be normal
