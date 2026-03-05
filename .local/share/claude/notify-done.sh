#!/bin/bash

# Lit le payload JSON de Claude Code sur stdin
INPUT=$(cat)

# Évite les boucles infinies
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_active', False))" 2>/dev/null)
if [ "$STOP_ACTIVE" = "True" ]; then
  exit 0
fi

# Dernier message
LAST_MSG=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
msg = d.get('last_assistant_message', '').strip().replace('\n', ' ')
if len(msg) > 120:
    msg = msg[:117] + '...'
print(msg)
" 2>/dev/null)

# Session et pane tmux
CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd', ''))" 2>/dev/null)

# Trouve le pane via le PID — remonte l'arbre jusqu'à trouver un pane_pid qui matche
PANE_INFO=$(python3 -c "
import subprocess, os

def get_ppid(pid):
    try:
        out = subprocess.check_output(['ps', '-o', 'ppid=', '-p', str(pid)], text=True).strip()
        return int(out)
    except:
        return None

# Liste tous les panes avec leur pid et path
panes = subprocess.check_output([
    '/opt/homebrew/bin/tmux', 'list-panes', '-a',
    '-F', '#{session_name}|#{window_index}|#{pane_index}|#{pane_id}|#{pane_pid}|#{pane_current_path}'
], text=True).strip().split('\n')

pane_pids = {}
for p in panes:
    parts = p.split('|')
    if len(parts) == 6:
        pane_pids[int(parts[4])] = p

# Remonte l'arbre de process depuis le PID courant
pid = os.getpid()
visited = set()
while pid and pid not in visited:
    visited.add(pid)
    if pid in pane_pids:
        print(pane_pids[pid])
        break
    pid = get_ppid(pid)
" 2>/dev/null)

TMUX_SESSION=$(echo "$PANE_INFO" | cut -d'|' -f1)
TMUX_WINDOW=$(echo "$PANE_INFO" | cut -d'|' -f2)
TMUX_PANE_NUM=$(echo "$PANE_INFO" | cut -d'|' -f3)
TMUX_PANE_ID=$(echo "$PANE_INFO" | cut -d'|' -f4)

if [ -n "$TMUX_SESSION" ]; then
  TITLE="CC :  ${TMUX_SESSION}   ${TMUX_WINDOW}"
  if [ -n "$TMUX_PANE_NUM" ] && [ "$TMUX_PANE_NUM" != "0" ]; then
    TITLE="${TITLE}  󰕮 ${TMUX_PANE_NUM}"
  fi
else
  TITLE="CC"
fi

# Script de focus au clic
FOCUS_SCRIPT="/tmp/claude-notify-focus-$$.sh"
cat > "$FOCUS_SCRIPT" << SCRIPT
#!/bin/bash
/opt/homebrew/bin/tmux switch-client -t '${TMUX_SESSION}' 2>/dev/null
/opt/homebrew/bin/tmux select-window -t '${TMUX_SESSION}:${TMUX_WINDOW}' 2>/dev/null
/opt/homebrew/bin/tmux select-pane -t '${TMUX_PANE_ID}' 2>/dev/null
open -a WezTerm 2>/dev/null
SCRIPT
chmod +x "$FOCUS_SCRIPT"

# Cloche sur la window tmux
if [ -n "$TMUX_PANE_ID" ]; then
  /opt/homebrew/bin/tmux set-option -w -t "$TMUX_PANE_ID" @notif "1" 2>/dev/null
  /opt/homebrew/bin/tmux refresh-client -S 2>/dev/null
fi

/opt/homebrew/bin/terminal-notifier \
  -title "$TITLE" \
  -message "${LAST_MSG:-Done}" \
  -group claude-done \
  -sound default \
  -execute "$FOCUS_SCRIPT" \
  2>/dev/null

exit 0
