#!/bin/sh
# Send a key to the yazi pane in the current window
# Usage: yazi-send-key.sh <key>
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
KEY="$1"
[ -z "$KEY" ] && exit 1
TMUX_BIN=$(command -v tmux)
p=$($TMUX_BIN list-panes -F '#{pane_id} #{pane_current_command}' | awk '$2=="yazi"{print $1; exit}')
[ -n "$p" ] && $TMUX_BIN send-keys -t "$p" "$KEY"
