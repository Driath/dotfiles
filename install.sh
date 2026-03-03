#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# WezTerm
mkdir -p "$HOME/.config/wezterm"
ln -sf "$DOTFILES/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
ln -sf "$DOTFILES/.config/wezterm/keybindings.md" "$HOME/.config/wezterm/keybindings.md"
echo "✓ WezTerm"

# tmux
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "✓ tmux"

echo "Done."
