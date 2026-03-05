#!/bin/sh
# Generates the pane-border-format string for tmux
# Called by: run-shell in ~/.tmux.conf
# Each section is on its own line for readability

# --- Active pane ---
ACTIVE_DOT='#[fg=cyan]●'
ACTIVE_NAME='#[fg=brightcyan]#W'
ACTIVE_PATH='#[fg=white] #{b:pane_current_path}'
ACTIVE_TITLE='#[fg=white] #T'
ACTIVE_STATS='#{?#{@pane_cpu},│ #[fg=brightblack]󰍛 #[fg=white]#{@pane_cpu} #[fg=brightblack]󰘚 #[fg=white]#{@pane_mem} ,}'
ACTIVE="${ACTIVE_DOT} ${ACTIVE_NAME} ${ACTIVE_PATH} ${ACTIVE_TITLE} ${ACTIVE_STATS}${ACTIVE_DOT}"

# --- Inactive pane ---
INACTIVE_DOT='#[fg=brightblack]○'
INACTIVE_NAME='#{pane_current_command}'
INACTIVE_PATH=' #{b:pane_current_path}'
INACTIVE_TITLE='#[fg=white] #T'
INACTIVE_STATS='#{?#{@pane_cpu},│ 󰍛 #{@pane_cpu} 󰘚 #{@pane_mem} ,}'
INACTIVE="${INACTIVE_DOT} ${INACTIVE_NAME} ${INACTIVE_PATH} ${INACTIVE_TITLE} ${INACTIVE_STATS}${INACTIVE_DOT}"

# --- Compose final format ---
FORMAT="#{?pane_active,${ACTIVE},${INACTIVE}}"

tmux set -gw pane-border-format "$FORMAT"
