#!/usr/bin/env bash
# Speech-to-text with Ollama post-processing correction.
# Usage: speech-to-text-ollama.sh [pane-id]

if ! command -v sox >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
fi

TMUX_BIN="$(command -v tmux)"
SOX_BIN="$(command -v sox)"
WHISPER_BIN="$(command -v whisper-cli)"
OLLAMA_BIN="$(command -v ollama)"
AUDIO_FILE="/tmp/stt-ollama-recording.wav"
PID_FILE="/tmp/stt-ollama-recording.pid"
MODEL_PATH="$HOME/.local/share/whisper-cpp/ggml-large-v3-turbo.bin"
# Fallback to base if turbo not available
[ -f "$MODEL_PATH" ] || MODEL_PATH="$HOME/.local/share/whisper-cpp/ggml-base.bin"

if [ -f "$PID_FILE" ]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null
  rm -f "$PID_FILE" "$AUDIO_FILE"
  "$TMUX_BIN" set -gu @stt_status
  "$TMUX_BIN" refresh-client -S
  exit 0
fi

"$TMUX_BIN" set -g @stt_status "rec+"
"$TMUX_BIN" refresh-client -S

"$SOX_BIN" -d -r 16000 -c 1 -b 16 "$AUDIO_FILE" silence 1 0.0 0% 1 1.5 1% &
echo $! > "$PID_FILE"
wait "$!" 2>/dev/null
rm -f "$PID_FILE"

"$TMUX_BIN" set -g @stt_status "trans+"
"$TMUX_BIN" refresh-client -S

if [ -f "$AUDIO_FILE" ]; then
  raw=$("$WHISPER_BIN" -m "$MODEL_PATH" -f "$AUDIO_FILE" -np -nt -l auto -t 8 2>/dev/null \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -v '^\[' \
    | tr '\n' ' ' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  if [ -n "$raw" ] && [ -n "$OLLAMA_BIN" ]; then
    "$TMUX_BIN" set -g @stt_status "llm+"
    "$TMUX_BIN" refresh-client -S
    text=$(echo "$raw" | "$OLLAMA_BIN" run qwen2.5:7b \
      "Corrige uniquement la ponctuation et les fautes évidentes de cette transcription vocale. Ne reformule pas. Garde les commandes shell, noms de fichiers et termes techniques intacts. Réponds avec le texte corrigé uniquement, sans explication." \
      2>/dev/null | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$text" ] && text="$raw"
  else
    text="$raw"
  fi

  if [ -n "$text" ]; then
    if [ -n "$1" ]; then
      "$TMUX_BIN" send-keys -t "$1" "$text" Enter
    else
      "$TMUX_BIN" send-keys "$text" Enter
    fi
  fi
  rm -f "$AUDIO_FILE"
fi

"$TMUX_BIN" set -gu @stt_status
"$TMUX_BIN" refresh-client -S
