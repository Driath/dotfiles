#!/bin/bash
# Updates @pane_cpu and @pane_mem for all panes in the current window

PANES=$(tmux list-panes -F '#{pane_id} #{pane_pid}' 2>/dev/null)
[ -z "$PANES" ] && exit 0

echo "$PANES" | while read -r PANE_ID PANE_PID; do
  CHILD=$(ps -axo pid=,ppid=,%cpu=,rss= 2>/dev/null | awk -v ppid="$PANE_PID" '$2 == ppid {print; exit}')
  if [ -z "$CHILD" ]; then
    tmux set -p -t "$PANE_ID" @pane_cpu "" 2>/dev/null
    tmux set -p -t "$PANE_ID" @pane_mem "" 2>/dev/null
    continue
  fi

  CPU=$(echo "$CHILD" | awk '{printf "%.0f", $3}')
  RSS_KB=$(echo "$CHILD" | awk '{print $4}')

  if [ "$RSS_KB" -ge 1048576 ] 2>/dev/null; then
    MEM="$(echo "$RSS_KB" | awk '{printf "%.1f", $1/1048576}')G"
  elif [ "$RSS_KB" -ge 1024 ] 2>/dev/null; then
    MEM="$(echo "$RSS_KB" | awk '{printf "%.0f", $1/1024}')M"
  else
    MEM="${RSS_KB}K"
  fi

  tmux set -p -t "$PANE_ID" @pane_cpu "$CPU%" 2>/dev/null
  tmux set -p -t "$PANE_ID" @pane_mem "$MEM" 2>/dev/null
done
