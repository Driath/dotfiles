#!/bin/sh
# Move current window to the next or previous session
# Usage: move-window-to-session.sh next|prev
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TMUX_BIN=$(command -v tmux)
DIR="$1"

current_session=$($TMUX_BIN display -p '#{session_name}')
sessions=$($TMUX_BIN list-sessions -F '#{session_name}')
count=$(echo "$sessions" | wc -l | tr -d ' ')

[ "$count" -le 1 ] && exit 0

# Find current session index and target
i=0
target=""
prev=""
first=""
last=""
while IFS= read -r s; do
  i=$((i + 1))
  [ -z "$first" ] && first="$s"
  last="$s"
  if [ "$s" = "$current_session" ]; then
    if [ "$DIR" = "prev" ] && [ -n "$prev" ]; then
      target="$prev"
    elif [ "$DIR" = "prev" ]; then
      target="$last"
    fi
  elif [ -n "$found" ] && [ "$DIR" = "next" ] && [ -z "$target" ]; then
    target="$s"
  fi
  [ "$s" = "$current_session" ] && found=1
  prev="$s"
done <<EOF
$sessions
EOF

# Wrap around
[ "$DIR" = "next" ] && [ -z "$target" ] && target="$first"
[ "$DIR" = "prev" ] && [ -z "$target" ] && target="$last"

[ -z "$target" ] && exit 0
[ "$target" = "$current_session" ] && exit 0

$TMUX_BIN move-window -a -t "$target:"
$TMUX_BIN switch-client -t "$target"
