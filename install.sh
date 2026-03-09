#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# Dependencies
echo "Installing dependencies..."
brew install pngpaste 2>/dev/null || true
brew install terminal-notifier 2>/dev/null || true
brew install whisper-cpp sox 2>/dev/null || true
pip3 install pyobjc-framework-Quartz 2>/dev/null || true
echo "✓ Dependencies"

# Nerd Fonts
echo "Installing fonts..."
brew install --cask \
  font-geist-mono-nerd-font \
  font-hack-nerd-font \
  font-fira-code-nerd-font \
  font-jetbrains-mono-nerd-font \
  font-commit-mono-nerd-font \
  font-meslo-lg-nerd-font \
  font-sauce-code-pro-nerd-font \
  font-inconsolata-nerd-font \
  font-blex-mono-nerd-font \
  font-victor-mono-nerd-font \
  font-iosevka-nerd-font \
  font-maple-mono-nf \
  2>/dev/null || true
echo "✓ Fonts"

# Speech-to-text model (whisper)
WHISPER_MODEL_DIR="$HOME/.local/share/whisper-cpp"
WHISPER_MODEL="$WHISPER_MODEL_DIR/ggml-base.bin"
if [ ! -f "$WHISPER_MODEL" ]; then
  mkdir -p "$WHISPER_MODEL_DIR"
  echo "Downloading whisper base model..."
  curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin" \
    -o "$WHISPER_MODEL" 2>/dev/null
  echo "✓ Whisper model"
else
  echo "✓ Whisper model already present"
fi

# Starship
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/.config/starship.toml" "$HOME/.config/starship.toml"
echo "✓ Starship"

# WezTerm
mkdir -p "$HOME/.config/wezterm"
ln -sf "$DOTFILES/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
echo "✓ WezTerm"

# Ghostty
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/.config/ghostty/config" "$HOME/.config/ghostty/config"
echo "✓ Ghostty"

# Yazi
mkdir -p "$HOME/.config/yazi"
for f in "$DOTFILES/.config/yazi"/*; do
  [ -f "$f" ] && ln -sf "$f" "$HOME/.config/yazi/$(basename "$f")"
done
echo "✓ Yazi"

# Neovim
brew install neovim 2>/dev/null || true
if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" 2>/dev/null
  rm -rf "$HOME/.config/nvim/.git"
  echo "✓ LazyVim starter installed"
fi
for f in "$DOTFILES/.config/nvim/lua/config"/*.lua; do
  [ -f "$f" ] && ln -sf "$f" "$HOME/.config/nvim/lua/config/$(basename "$f")"
done
for f in "$DOTFILES/.config/nvim/lua/plugins"/*.lua; do
  [ -f "$f" ] && ln -sf "$f" "$HOME/.config/nvim/lua/plugins/$(basename "$f")"
done
echo "✓ Neovim"

# tmux
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "✓ tmux"

# TPM (tmux plugin manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null
  echo "✓ TPM installed"
else
  echo "✓ TPM already installed"
fi
# Install tmux plugins
"$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
echo "✓ tmux plugins"

# Config
mkdir -p "$HOME/.local/etc"
ln -sf "$DOTFILES/.local/etc/terminal.conf" "$HOME/.local/etc/terminal.conf"
echo "✓ Config (.local/etc)"

# Scripts
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES/.local/bin"/*.sh; do
  ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
  chmod +x "$HOME/.local/bin/$(basename "$script")"
done
echo "✓ Scripts (.local/bin)"

# Clipboard paste script
mkdir -p "$HOME/.local/share/wezterm/clipboard-images"
ln -sf "$DOTFILES/.local/share/wezterm/clipboard-paste.sh" "$HOME/.local/share/wezterm/clipboard-paste.sh"
chmod +x "$HOME/.local/share/wezterm/clipboard-paste.sh"

# Cleanup old clipboard images (older than 7 days)
if command -v crontab >/dev/null; then
  (crontab -l 2>/dev/null | grep -v "clipboard-images"; echo "0 0 * * * find $HOME/.local/share/wezterm/clipboard-images -name '*.png' -mtime +7 -delete") | crontab -
  echo "✓ Clipboard cleanup scheduled"
fi
echo "✓ Clipboard paste"

# Claude Code hooks
mkdir -p "$HOME/.local/share/claude"
ln -sf "$DOTFILES/.local/share/claude/notify-done.sh" "$HOME/.local/share/claude/notify-done.sh"
chmod +x "$HOME/.local/share/claude/notify-done.sh"

# Claude Code skills
mkdir -p "$HOME/.claude/skills"
for skill in "$DOTFILES/.claude/skills"/*/; do
  [ -d "$skill" ] || continue
  target="$HOME/.claude/skills/$(basename "$skill")"
  rm -f "$target" 2>/dev/null
  ln -sf "$skill" "$target"
done
echo "✓ Claude Code skills"
# Inject Stop hook into ~/.claude/settings.json if not already present
if [ -f "$HOME/.claude/settings.json" ]; then
  python3 -c "
import json, sys
path = '$HOME/.claude/settings.json'
with open(path) as f:
    s = json.load(f)
hook = {'type': 'command', 'command': '$HOME/.local/share/claude/notify-done.sh', 'async': True}
entry = {'matcher': '', 'hooks': [hook]}
s.setdefault('hooks', {}).setdefault('Stop', [])
if not any(h.get('hooks', [{}])[0].get('command', '').endswith('notify-done.sh') for h in s['hooks']['Stop']):
    s['hooks']['Stop'].append(entry)
    with open(path, 'w') as f:
        json.dump(s, f, indent=2)
    print('✓ Claude hook injected')
else:
    print('✓ Claude hook already present')
"
else
  echo "⚠ ~/.claude/settings.json not found, skipping hook injection"
fi
echo "✓ Claude Code notifications"

echo "Done. Restart WezTerm/Ghostty and run: tmux kill-server"
