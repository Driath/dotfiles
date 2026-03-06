#!/bin/sh
# Generates the pane-border-format string for tmux
# Called by: run-shell in ~/.tmux.conf
# Each section is on its own line for readability

# --- Active pane ---
ACTIVE_DOT='#[fg=#{@color-active}]●'
ACTIVE_NAME='#[fg=#{@color-accent}]#W'
ACTIVE_PATH='#[fg=#{@color-text}] #{b:pane_current_path}'
ACTIVE_TITLE='#[fg=#{@color-text}] #{=30:pane_title}'
ACTIVE_GIT=''
ACTIVE_STATS='#{?#{@pane_cpu},#[fg=#{@color-separator}]│ #[fg=#{@color-inactive}]󰍛 #[fg=#{@color-text}]#{@pane_cpu} #[fg=#{@color-inactive}]󰘚 #[fg=#{@color-text}]#{@pane_mem} ,}'
ACTIVE="${ACTIVE_DOT} ${ACTIVE_NAME} ${ACTIVE_PATH} ${ACTIVE_TITLE} ${ACTIVE_GIT}${ACTIVE_STATS}${ACTIVE_DOT}"

# --- Inactive pane ---
INACTIVE_DOT='#[fg=#{@color-inactive}]○'
INACTIVE_NAME='#{pane_current_command}'
INACTIVE_PATH=' #{b:pane_current_path}'
INACTIVE_TITLE='#[fg=#{@color-inactive}] #{=30:pane_title}'
INACTIVE_GIT=''
INACTIVE_STATS='#{?#{@pane_cpu},#[fg=#{@color-inactive}]│ 󰍛 #{@pane_cpu} 󰘚 #{@pane_mem} ,}'
INACTIVE="${INACTIVE_DOT} ${INACTIVE_NAME} ${INACTIVE_PATH} ${INACTIVE_TITLE} ${INACTIVE_GIT}${INACTIVE_STATS}${INACTIVE_DOT}"

# --- Yazi pane (just the dot) ---
YAZI_ACTIVE="${ACTIVE_DOT}"
YAZI_INACTIVE="${INACTIVE_DOT}"
YAZI="#{?pane_active,${YAZI_ACTIVE},${YAZI_INACTIVE}}"

# --- Compose final format ---
NORMAL="#{?pane_active,${ACTIVE},${INACTIVE}}"
FORMAT="#{?#{m:yazi,#{pane_current_command}},${YAZI},${NORMAL}}"

tmux set -gw pane-border-format "$FORMAT"
