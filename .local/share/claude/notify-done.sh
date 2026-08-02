#!/bin/bash

# Dependency check
_check_dep() {
  local bin=$1 install=$2
  command -v "$bin" >/dev/null 2>&1 && { echo $(command -v "$bin"); return 0; }
  echo "⚠ $bin not found. Install it with: $install" >&2
  return 1
}

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

# Titre simple (plus de session/pane tmux)
TITLE="CC"

$NOTIFIER_BIN \
  -title "$TITLE" \
  -subtitle "$USER_PROMPT" \
  -message "$ASSISTANT_MSG" \
  -group claude-done \
  -sound default \
  2>/dev/null

exit 0
