# Dotfiles - Notes pour Claude

## Règles importantes

### Édition de ~/.tmux.conf
- **Ne jamais utiliser `sed` ou le `Write` tool** pour modifier des lignes contenant des caractères nerd font (icônes Unicode)
- Ces caractères sont des codepoints spéciaux qui se cassent silencieusement avec ces outils
- **Toujours utiliser Python en binaire** pour modifier ces lignes :
  ```python
  import os
  path = os.path.expanduser('~/.tmux.conf')
  content = open(path, 'rb').read()
  content = content.replace(b'old_bytes', b'new_bytes')
  open(path, 'wb').write(content)
  ```
- Pour trouver les bytes exacts d'une icône : `python3 -c "print('󰕮'.encode('utf-8').hex())"`
- Pour recharger tmux sans demander : `tmux source ~/.tmux.conf`

### Architecture
- **WezTerm** = renderer pur (pas de tabs natifs, pas de keybindings par défaut)
- **tmux** = gère tout (sessions, windows, panes)
- Les keybindings macOS (`Cmd+T`, `Cmd+W`, etc.) dans WezTerm envoient des commandes tmux
- Prefix tmux = `Ctrl+Space`

### Paths importants
- Config WezTerm : `~/.config/wezterm/wezterm.lua`
- Config tmux : `~/.tmux.conf`
- Script clipboard : `~/.local/share/wezterm/clipboard-paste.sh`
- tmux binaire : `$(command -v tmux)`
