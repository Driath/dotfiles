#!/bin/sh
export PATH="/opt/homebrew/bin:$PATH"
n=$(tmux display -p '#{@notif}')
tmux set -w @notif $(( ${n:-0} + 1 ))
