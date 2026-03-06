#!/bin/sh
# Count windows with @notif set across all sessions
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TMUX_BIN=$(command -v tmux)
count=$($TMUX_BIN list-windows -a -F '#{@notif}' 2>/dev/null | awk '{s+=$1} END {print s+0}')
[ "$count" -gt 0 ] && printf '%s' "$count"
