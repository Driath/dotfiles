#!/bin/zsh
# Smart clipboard paste for tmux:
#   - image + pane = Claude Code → délègue à son Ctrl+V natif (attache l'image)
#   - image + pane ≠ Claude Code → downscale + colle le path
#   - texte                      → paste-buffer (gère les gros presse-papiers)
export PATH="/opt/homebrew/bin:$PATH"

# Claude Code set son process title à sa version (ex: "2.1.116"), donc
# pane_current_command ne vaut pas "claude". On résout via le PID du shell.
is_claude_code_pane() {
  local pane_pid kids p comm
  pane_pid=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{pane_pid}' 2>/dev/null) || return 1
  [[ -n "$pane_pid" ]] || return 1
  kids=$(pgrep -P "$pane_pid" 2>/dev/null) || return 1
  for p in ${=kids}; do
    comm=$(ps -p "$p" -o comm= 2>/dev/null | tr -d ' ')
    [[ "$comm" == "claude" ]] && return 0
  done
  return 1
}

DIR="$HOME/.local/share/wezterm/clipboard-images"
mkdir -p "$DIR"
FILE="$DIR/clipboard-image-$$-$(date +%s).png"

if /opt/homebrew/bin/pngpaste "$FILE" 2>/dev/null && [[ -s "$FILE" ]]; then
  if is_claude_code_pane; then
    # Claude Code lit le presse-papier lui-même sur Ctrl+V et attache l'image
    # comme pièce jointe. On ne touche pas le clipboard, on n'injecte pas de path.
    rm -f "$FILE"
    tmux send-keys C-v
    exit 0
  fi
  # Fallback hors Claude Code : downscale si > 1568px puis colle le path.
  DIMS=$(sips -g pixelWidth -g pixelHeight "$FILE" 2>/dev/null | awk '/pixel(Width|Height)/ {print $2}')
  MAX=$(echo "$DIMS" | sort -n | tail -1)
  if [[ -n "$MAX" && "$MAX" -gt 1568 ]]; then
    sips -Z 1568 "$FILE" --out "$FILE" >/dev/null 2>&1
  fi
  tmux send-keys -l "$FILE"
  exit 0
fi
rm -f "$FILE"

TEXT=$(pbpaste)
if [[ -z "$TEXT" ]]; then
  echo "clipboard-paste: clipboard is empty or not text" >&2
  exit 1
fi
# load-buffer via stdin évite la limite "command too long" de send-keys -l
# sur les gros clipboards (> quelques Ko)
printf '%s' "$TEXT" | tmux load-buffer -b clipboard-paste -
tmux paste-buffer -b clipboard-paste -d
