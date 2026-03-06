#!/usr/bin/env bash
# Toggle yazi sidebar in the current tmux window
# If a yazi pane exists, kill it and restore layout. Otherwise, split left 30%.

# Ensure Homebrew PATH when run from tmux run-shell (minimal env)
if ! command -v tmux >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
fi

TMUX_BIN="$(command -v tmux)"
YAZI_BIN="$(command -v yazi)"

# Find a pane in the current window running yazi
yazi_pane=$("$TMUX_BIN" list-panes -F '#{pane_id} #{pane_current_command}' \
  | awk '$2 == "yazi" { print $1; exit }')

if [ -n "$yazi_pane" ]; then
  # Restore saved layout, then kill yazi pane
  saved_layout=$("$TMUX_BIN" show-option -wqv @yazi_layout)
  "$TMUX_BIN" kill-pane -t "$yazi_pane"
  if [ -n "$saved_layout" ]; then
    "$TMUX_BIN" select-layout "$saved_layout"
    "$TMUX_BIN" set-option -wu @yazi_layout
  fi
else
  # Save current layout before splitting
  "$TMUX_BIN" set-option -w @yazi_layout "$("$TMUX_BIN" display-message -p '#{window_layout}')"
  # Get current pane's path for yazi to start in
  pane_path=$("$TMUX_BIN" display-message -p '#{pane_current_path}')
  # Split left 30% (minimum 80 columns)
  win_width=$("$TMUX_BIN" display-message -p '#{window_width}')
  size=$(( win_width * 33 / 100 ))
  [ "$size" -lt 48 ] && size=48
  "$TMUX_BIN" split-window -hbf -l "$size" -c "$pane_path" "$YAZI_BIN"
fi
