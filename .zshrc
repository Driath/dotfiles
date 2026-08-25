eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/matthieuczeski/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/matthieuczeski/.bun/_bun" ] && source "/Users/matthieuczeski/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by Antigravity
export PATH="/Users/matthieuczeski/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

[[ -f "$HOME/.config/kaku/zsh/kaku.zsh" ]] && source "$HOME/.config/kaku/zsh/kaku.zsh" # Kaku Shell Integration

# fzf
source <(fzf --zsh)
export FZF_CTRL_T_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:50 {}'"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"

# Option+Arrow word jump (WezTerm sends \e[1;3C / \e[1;3D, ZLE has no default bind for it)
bindkey $'\e[1;3C' forward-word
bindkey $'\e[1;3D' backward-word

# aliases
alias ls="eza --icons"
alias ll="eza --icons -la"
alias tree="eza --tree --icons"
alias cat="bat"
alias probe="bun run probe"

export EDITOR="nvim"

source /Users/matthieuczeski/.config/broot/launcher/bash/br

# Claude Code
alias super-claude='claude --dangerously-skip-permissions'

[[ ":$PATH:" != *":$HOME/.config/kaku/zsh/bin:"* ]] && export PATH="$HOME/.config/kaku/zsh/bin:$PATH" # Kaku PATH Integration

# opencode
export PATH=/Users/matthieuczeski/.opencode/bin:$PATH

# DeepSeek API key (shared with claude-deepseek launcher)
[ -f ~/.config/claude-deepseek/env ] && set -a && source ~/.config/claude-deepseek/env && set +a
export NEXT_BROWSER_HEADLESS=1

# agent-browser default flags (suppress Chrome automation banner)
export AGENT_BROWSER_FLAGS="--auto-connect --headed"
alias ab='agent-browser $AGENT_BROWSER_FLAGS open'
alias ab-snapshot='agent-browser snapshot -i'
alias ab-click='agent-browser click'

# Dia browser with CDP for agent-browser
alias dia='open -a Dia --args --remote-debugging-port=9222 --disable-features=CalculateNativeWinOcclusion --disable-backgrounding-occluded-windows --disable-background-timer-throttling --disable-renderer-backgrounding'

# mimocode
export PATH=/Users/matthieuczeski/.mimocode/bin:$PATH

# Added by Antigravity IDE
export PATH="/Users/matthieuczeski/.antigravity-ide/antigravity-ide/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/matthieuczeski/.local/bin:$PATH"

# vibe-island statusline chain — opt-in, read by repo-local statusline hooks
# that append their own segment (e.g. czeski.fr's .claude/hooks/statusline.sh)
export CZESKI_STATUSLINE_CHAIN="$HOME/.vibe-island/bin/vibe-island-statusline-chain"

# >>> headroom persistent env >>>
export HEADROOM_PORT="8787"
export HEADROOM_HOST="127.0.0.1"
export HEADROOM_MODE="token"
export HEADROOM_BACKEND="anthropic"
export HEADROOM_TELEMETRY="on"
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787"
export ENABLE_TOOL_SEARCH="true"
export OPENAI_BASE_URL="http://127.0.0.1:8787/v1"
# <<< headroom persistent env <<<
