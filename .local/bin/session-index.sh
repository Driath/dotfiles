#!/bin/sh
# Update @session_index for the attached session
# Called by tmux hooks: session-created, session-closed, client-session-changed
session=$(tmux display-message -p '#{session_name}' 2>/dev/null) || exit 0
idx=$(tmux list-sessions -F '#{session_name}' | awk -v s="$session" '$0==s{print NR}')
tmux set -g @session_index "$idx"
