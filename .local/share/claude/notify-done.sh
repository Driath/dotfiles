#!/bin/bash

# Lit le payload JSON de Claude Code sur stdin
INPUT=$(cat)

# Si c'est déjà un hook stop actif (évite les boucles infinies)
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_active', False))" 2>/dev/null)
if [ "$STOP_ACTIVE" = "True" ]; then
  exit 0
fi

# Extrait le dernier message et le cwd
LAST_MSG=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
msg = d.get('last_assistant_message', '')
# Prend les 100 premiers chars pour la notif
msg = msg.strip().replace('\n', ' ')
if len(msg) > 120:
    msg = msg[:117] + '...'
print(msg)
" 2>/dev/null)

CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd', ''))" 2>/dev/null)
TITLE=$(basename "$CWD")

/opt/homebrew/bin/terminal-notifier \
  -title "Claude ✓" \
  -subtitle "$TITLE" \
  -message "${LAST_MSG:-Done}" \
  -group claude-done \
  -sound default \
  2>/dev/null

exit 0
