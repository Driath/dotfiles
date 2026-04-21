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
- **Ghostty** = terminal primaire (keybindings via CSI user-keys `\x1b[900~..\x1b[931~`)
- **WezTerm** = terminal secondaire (dual, en cours d'alignement sur les mêmes user-keys)
- **tmux** = gère tout (sessions, windows, panes) — Prefix = `Ctrl+Space`
- Les keybindings macOS (`Cmd+T`, `Cmd+W`, etc.) dans les deux terminaux envoient des séquences CSI qui sont interceptées par tmux root table et routées vers `bawi`

### bawi — CLI d'abstraction tmux
- Projet : `~/Projects/bawi` (Rust)
- Binaire : `~/.local/bin/bawi` (symlink vers `~/Projects/bawi/target/release/bawi`)
- Remplace les appels tmux directs dans Ghostty/WezTerm/scripts
- `bawi pane nav left/right/up/down` → `tmux select-pane` direct (pas de send-keys)
- L'app Android SSH appellera `bawi` pour contrôler tmux sans interférer avec le terminal
- Config mobile : `~/.config/bawi/mobile.toml`

### Paths importants
- Config Ghostty : `~/.config/ghostty/config` (primaire)
- Config WezTerm : `~/.config/wezterm/wezterm.lua` (secondaire)
- Config tmux : `~/.tmux.conf`
- Script clipboard : `~/.local/bin/clipboard-paste-tmux.sh`
- tmux binaire : `$(command -v tmux)`
