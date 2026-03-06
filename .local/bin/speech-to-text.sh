#!/usr/bin/env bash
# Speech-to-text: Cmd+M starts recording, auto-stops after 2s silence, transcribes, injects text.
# Second Cmd+M while recording cancels.

# Ensure Homebrew PATH when run from tmux run-shell (minimal env)
if ! command -v sox >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
fi

TMUX_BIN="$(command -v tmux)"
SOX_BIN="$(command -v sox)"
WHISPER_BIN="$(command -v whisper-cli)"
AUDIO_FILE="/tmp/stt-recording.wav"
PID_FILE="/tmp/stt-recording.pid"
MODEL_PATH="$HOME/.local/share/whisper-cpp/ggml-base.bin"

# If already recording, cancel
if [ -f "$PID_FILE" ]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null
  rm -f "$PID_FILE" "$AUDIO_FILE"
  "$TMUX_BIN" set -gu @stt_status
  "$TMUX_BIN" refresh-client -S
  exit 0
fi

# --- START RECORDING ---
"$TMUX_BIN" set -g @stt_status "🎙"
"$TMUX_BIN" refresh-client -S

# Record immediately, stop after 1.5s of silence
"$SOX_BIN" -d -r 16000 -c 1 -b 16 "$AUDIO_FILE" silence 1 0.0 0% 1 1.5 1% &
echo $! > "$PID_FILE"

# Wait for sox to finish (silence detected)
wait "$!" 2>/dev/null
rm -f "$PID_FILE"

# --- TRANSCRIBE ---
"$TMUX_BIN" set -g @stt_status "✍"
"$TMUX_BIN" refresh-client -S

if [ -f "$AUDIO_FILE" ]; then
  text=$("$WHISPER_BIN" -m "$MODEL_PATH" -f "$AUDIO_FILE" -np -nt -l auto 2>/dev/null \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -v '^\[' \
    | tr '\n' ' ' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  if [ -n "$text" ]; then
    "$TMUX_BIN" send-keys "$text"
  fi
  rm -f "$AUDIO_FILE"
fi

# Clear statusbar
"$TMUX_BIN" set -gu @stt_status
"$TMUX_BIN" refresh-client -S
