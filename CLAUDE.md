# Dotfiles - Notes pour Claude

## Architecture
- **Ghostty** = terminal primaire (keybindings via CSI user-keys `\x1b[900~..\x1b[931~`)
- **WezTerm** = terminal secondaire (dual, en cours d'alignement sur les mêmes user-keys)
- Les keybindings macOS (`Cmd+T`, `Cmd+W`, etc.) sont gérés nativement par chaque terminal (tabs, windows, panes)

### Paths importants
- Config Ghostty : `~/.config/ghostty/config` (primaire)
- Config WezTerm : `~/.config/wezterm/wezterm.lua` (secondaire)
- Script capture : `~/.local/bin/screenshot.sh`
