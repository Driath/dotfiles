#!/bin/sh
# Open a new tmux window in the yazi pane's current directory
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TMUX_BIN=$(command -v tmux)
p=$($TMUX_BIN list-panes -F '#{pane_id} #{pane_current_command}' | awk '$2=="yazi"{print $1; exit}')
[ -z "$p" ] && exit 0
dir=$($TMUX_BIN display -t "$p" -p '#{pane_current_path}')
[ -n "$dir" ] && $TMUX_BIN new-window -c "$dir"
