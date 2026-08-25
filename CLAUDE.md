# Dotfiles - Notes pour Claude

## Architecture
- **Ghostty** = terminal primaire, config vide : 100% défauts natifs de l'app (pas de thème, pas de police custom, pas de keybinding custom)
- **WezTerm** = terminal secondaire, garde sa config custom propre (`wezterm.lua`)
- Les keybindings macOS (`Cmd+T`, `Cmd+W`, etc.) sont gérés nativement par chaque terminal (tabs, windows, panes)

### Paths importants
- Config Ghostty : `~/.config/ghostty/config` (primaire, fichier vide intentionnellement)
- Config WezTerm : `~/.config/wezterm/wezterm.lua` (secondaire)
- Script capture : `~/.local/bin/screenshot.sh`
