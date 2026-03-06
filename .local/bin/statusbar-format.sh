#!/bin/sh
# Generates status-left, status-right and window-status-format for tmux
# Called by: run-shell in ~/.tmux.conf
# Each component is decomposed for readability

# ============================================================
# STATUS-LEFT
# ============================================================
SESSION_ICON='#[fg=#{@color-active}] '
SESSION_NAME='#[fg=#{@color-text},dim]#{?#{!=:#S,},#S ,}'
SESSION_INDEX='#{?#{>:#{server_sessions},1},#[fg=#{@color-text}]#{@session_index}#[fg=#{@color-inactive}]/#{server_sessions},}'
SEPARATOR='#[fg=#{@color-separator}]▎ '

STATUS_LEFT="${SESSION_ICON}${SESSION_NAME}${SESSION_INDEX} ${SEPARATOR}"

# ============================================================
# STATUS-RIGHT
# ============================================================
PANE_STATS='#(~/.local/bin/pane-stats-update.sh)'
PREFIX_INDICATOR='#{?client_prefix,#[fg=#{@color-warning}]󰌌 ,}'
ZOOM_INDICATOR='#{?window_zoomed_flag,#[fg=#{@color-warning}]󰍉  ,}'
STT_REC='#{?#{==:#{@stt_status},rec},#[fg=#{@color-info}]󰍬 #[fg=#{@color-warning}]󰋎 ,}'
STT_TRANS='#{?#{==:#{@stt_status},trans},#[fg=#{@color-info}]󰍬 #[fg=#{@color-warning}]󰔟 ,}'
STT_INDICATOR="${STT_REC}${STT_TRANS}"
SYSTEM_METRICS='#[fg=#{@color-inactive},dim]#(ping -c1 -t1 1.1.1.1 >/dev/null 2>&1 && echo "󰤨" || echo "󰤭") 󰁾 #{battery_percentage}  󰍛 #{cpu_percentage}  󰘚 #{ram_percentage}'
DATETIME='#[fg=#{@color-inactive}]󰅐 %d/%m  %H:%M'

STATUS_RIGHT="${PANE_STATS}${STT_INDICATOR}${PREFIX_INDICATOR}${ZOOM_INDICATOR}${SYSTEM_METRICS}  ${DATETIME}"

# ============================================================
# WINDOW FORMAT (shared components)
# ============================================================
PANES_ICON='#{?#{>:#{window_panes},1},#[fg=#{@color-info}]󰕮 ,}'
IS_SHELL='#{||:#{==:#{pane_current_command},zsh},#{||:#{==:#{pane_current_command},bash},#{==:#{pane_current_command},fish}}}'
PATH_DISPLAY="#{?${IS_SHELL},󰉋 #{b:pane_current_path},#{pane_current_command}  󰉋 #{b:pane_current_path}}"

# --- Window inactive ---
NOTIF_ICON='#{?#{@notif},#[fg=#{@color-warning}]󱅫 ,}'
WIN_INACTIVE="#[fg=#{@color-inactive}] #I #[fg=#{@color-text}]${PATH_DISPLAY} ${NOTIF_ICON}${PANES_ICON}"

# --- Window active ---
WIN_ACTIVE="#[fg=#{@color-active}] #I #[fg=#{@color-text},bold]${PATH_DISPLAY} ${PANES_ICON}#{?window_zoomed_flag,#[fg=#{@color-warning}]󰍉 ,}"

# ============================================================
# Apply to tmux
# ============================================================
tmux set -g status-left "$STATUS_LEFT"
tmux set -g status-right "$STATUS_RIGHT"
tmux set -g window-status-format "$WIN_INACTIVE"
tmux set -g window-status-current-format "$WIN_ACTIVE"
