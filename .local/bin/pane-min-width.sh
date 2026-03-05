#!/usr/bin/env bash
# Enforce minimum pane width of 40 columns after any resize
MIN_WIDTH=40
TMUX_BIN="$(command -v tmux)"

"$TMUX_BIN" list-panes -F '#{pane_id} #{pane_width}' | while read -r id width; do
  if [ "$width" -lt "$MIN_WIDTH" ]; then
    "$TMUX_BIN" resize-pane -t "$id" -x "$MIN_WIDTH" 2>/dev/null
  fi
done
