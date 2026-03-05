#!/bin/bash

# Dependency check
_check_dep() {
  local bin=$1 install=$2
  command -v "$bin" >/dev/null 2>&1 && { echo $(command -v "$bin"); return 0; }
  echo "⚠ $bin not found. Install it with: $install" >&2
  return 1
}

TMUX_BIN=$(_check_dep tmux "brew install tmux") || exit 0
NOTIFIER_BIN=$(_check_dep terminal-notifier "brew install terminal-notifier") || exit 0

# Lit le payload JSON de Claude Code sur stdin
INPUT=$(cat)

# Évite les boucles infinies
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_active', False))" 2>/dev/null)
if [ "$STOP_ACTIVE" = "True" ]; then
  exit 0
fi

# Dernier prompt user (subtitle) + réponse assistant (message)
NOTIF_DATA=$(echo "$INPUT" | python3 -c "
import sys, json, os
d = json.load(sys.stdin)
transcript = d.get('transcript_path', '')
user_msg = ''
if transcript and os.path.exists(transcript):
    with open(transcript) as f:
        for line in f:
            try:
                entry = json.loads(line)
                if entry.get('type') == 'user':
                    text = entry.get('message', {}).get('content', '')
                    if isinstance(text, list):
                        text = ' '.join(t.get('text', '') for t in text if isinstance(t, dict) and t.get('type') == 'text')
                    elif not isinstance(text, str):
                        text = ''
                    if text.strip():
                        user_msg = text.strip()
            except:
                pass
assistant_msg = d.get('last_assistant_message', '').strip()
def trunc(m):
    m = m.replace('\n', ' ').replace('\t', ' ')
    return m[:117] + '...' if len(m) > 120 else m
print(json.dumps({'user': trunc(user_msg), 'assistant': trunc(assistant_msg)}))
" 2>/dev/null)

USER_PROMPT=$(echo "$NOTIF_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('user',''))" 2>/dev/null)
ASSISTANT_MSG=$(echo "$NOTIF_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('assistant',''))" 2>/dev/null)
USER_PROMPT="${USER_PROMPT:-Prompt}"
ASSISTANT_MSG="${ASSISTANT_MSG:-Done}"

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
    '$TMUX_BIN', 'list-panes', '-a',
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

TMUX_SESSION_TOTAL=$($TMUX_BIN list-sessions 2>/dev/null | wc -l | tr -d " ")
TMUX_SESSION_IDX=$($TMUX_BIN list-sessions 2>/dev/null | grep -n "^$(echo $TMUX_SESSION):" | cut -d: -f1)

if [ -n "$TMUX_SESSION" ]; then
  TITLE="CC : ${TMUX_SESSION} ${TMUX_SESSION_IDX:-1}/${TMUX_SESSION_TOTAL:-1} > w${TMUX_WINDOW}"
  if [ -n "$TMUX_PANE_NUM" ] && [ "$TMUX_PANE_NUM" \!= "0" ]; then
    TITLE="${TITLE} > p${TMUX_PANE_NUM}"
  fi
else
  TITLE="CC"
fi

# Script de focus au clic
FOCUS_SCRIPT="/tmp/claude-notify-focus-$$.sh"
cat > "$FOCUS_SCRIPT" << SCRIPT
#!/bin/bash
$TMUX_BIN switch-client -t '${TMUX_SESSION}' 2>/dev/null
$TMUX_BIN select-window -t '${TMUX_SESSION}:${TMUX_WINDOW}' 2>/dev/null
$TMUX_BIN select-pane -t '${TMUX_PANE_ID}' 2>/dev/null
open -a WezTerm 2>/dev/null
SCRIPT
chmod +x "$FOCUS_SCRIPT"

# Cloche sur la window tmux
if [ -n "$TMUX_PANE_ID" ]; then
  $TMUX_BIN set-option -w -t "$TMUX_PANE_ID" @notif "1" 2>/dev/null
  $TMUX_BIN refresh-client -S 2>/dev/null
fi

$NOTIFIER_BIN \
  -title "$TITLE" \
  -subtitle "$USER_PROMPT" \
  -message "$ASSISTANT_MSG" \
  -group claude-done \
  -sound default \
  -execute "$FOCUS_SCRIPT" \
  2>/dev/null

exit 0
