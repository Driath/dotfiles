#!/bin/sh
# Generates the pane-border-format string for tmux
# Called by: run-shell in ~/.tmux.conf
# Each section is on its own line for readability

# --- Active pane ---
ACTIVE_DOT='#[fg=#{@color-active}]●'
ACTIVE_NAME='#[fg=#{@color-accent}]#W'
ACTIVE_PATH='#[fg=#{@color-text}] #{b:pane_current_path}'
ACTIVE_TITLE='#[fg=#{@color-text}] #T'
ACTIVE_GIT='#{?GITMUX_REPO,#[fg=#{@color-inactive}]│ #[fg=#{@color-info}]󰘬 #[fg=#{@color-text}]#{GITMUX_BRANCH}#{?GITMUX_CLEAN,, #[fg=#{@color-warning}]+#{GITMUX_STAGED} ~#{GITMUX_CHANGED} ?#{GITMUX_UNTRACKED}} ,}'
ACTIVE_STATS='#{?#{@pane_cpu},│ #[fg=#{@color-inactive}]󰍛 #[fg=#{@color-text}]#{@pane_cpu} #[fg=#{@color-inactive}]󰘚 #[fg=#{@color-text}]#{@pane_mem} ,}'
ACTIVE="${ACTIVE_DOT} ${ACTIVE_NAME} ${ACTIVE_PATH} ${ACTIVE_TITLE} ${ACTIVE_GIT}${ACTIVE_STATS}${ACTIVE_DOT}"

# --- Inactive pane ---
INACTIVE_DOT='#[fg=#{@color-inactive}]○'
INACTIVE_NAME='#{pane_current_command}'
INACTIVE_PATH=' #{b:pane_current_path}'
INACTIVE_TITLE='#[fg=#{@color-inactive}] #T'
INACTIVE_GIT='#{?GITMUX_REPO,#[fg=#{@color-inactive}]│ 󰘬 #{GITMUX_BRANCH}#{?GITMUX_CLEAN,, #[fg=#{@color-warning}]+#{GITMUX_STAGED} ~#{GITMUX_CHANGED} ?#{GITMUX_UNTRACKED}} ,}'
INACTIVE_STATS='#{?#{@pane_cpu},│ 󰍛 #{@pane_cpu} 󰘚 #{@pane_mem} ,}'
INACTIVE="${INACTIVE_DOT} ${INACTIVE_NAME} ${INACTIVE_PATH} ${INACTIVE_TITLE} ${INACTIVE_GIT}${INACTIVE_STATS}${INACTIVE_DOT}"

# --- Compose final format ---
FORMAT="#{?pane_active,${ACTIVE},${INACTIVE}}"

tmux set -gw pane-border-format "$FORMAT"
