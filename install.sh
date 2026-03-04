#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# Dependencies
echo "Installing dependencies..."
brew install pngpaste 2>/dev/null || true
echo "✓ Dependencies"

# WezTerm
mkdir -p "$HOME/.config/wezterm"
ln -sf "$DOTFILES/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
echo "✓ WezTerm"

# tmux
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "✓ tmux"

# Clipboard paste script
mkdir -p "$HOME/.local/share/wezterm/clipboard-images"
ln -sf "$DOTFILES/.local/share/wezterm/clipboard-paste.sh" "$HOME/.local/share/wezterm/clipboard-paste.sh"
chmod +x "$HOME/.local/share/wezterm/clipboard-paste.sh"
echo "✓ Clipboard paste"

echo "Done. Restart WezTerm and run: tmux kill-server"
