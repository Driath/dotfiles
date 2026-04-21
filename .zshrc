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

# aliases
alias ls="eza --icons"
alias ll="eza --icons -la"
alias tree="eza --tree --icons"
alias cat="bat"

export EDITOR="nvim"

source /Users/matthieuczeski/.config/broot/launcher/bash/br

# bawi / Claude Code
alias claude='claude --teammate-mode tmux'
alias super-claude='claude --dangerously-skip-permissions'

[[ ":$PATH:" != *":$HOME/.config/kaku/zsh/bin:"* ]] && export PATH="$HOME/.config/kaku/zsh/bin:$PATH" # Kaku PATH Integration

# opencode
export PATH=/Users/matthieuczeski/.opencode/bin:$PATH
