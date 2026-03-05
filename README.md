# dotfiles

WezTerm + tmux setup for macOS.

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) — `brew install terminal-notifier`
- [tpm](https://github.com/tmux-plugins/tpm) — `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- Python 3 (included on macOS)

## Install

```bash
git clone https://github.com/matthieuczeski/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then restart WezTerm and run `tmux kill-server`.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Keybindings

### Sessions
| Shortcut | Action |
|----------|--------|
| `Cmd+N` | New session |
| `Cmd+R` | Rename session |
| `Cmd+↑/↓` | Navigate sessions |

### Windows
| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New window |
| `Cmd+W` | Close window |
| `Cmd+←/→` | Navigate windows |
| `Cmd+&/é/"/'/(' | Jump to window 1-5 |

### Panes
| Shortcut | Action |
|----------|--------|
| `Cmd+D` | Split horizontal |
| `Cmd+Shift+D` | Split vertical |
| `Cmd+Alt+←→↑↓` | Navigate panes |
| `Cmd+Alt+Shift+←→↑↓` | Swap panes |
| `Cmd+Alt+F` | Zoom pane (toggle) |

### Other
| Shortcut | Action |
|----------|--------|
| `Cmd+C` | Copy (if selection) or Ctrl+C |
| `Cmd+V` | Paste |
| `Cmd+F` | Toggle fullscreen |
| `Cmd++/-/0` | Font size |
| `Cmd+</> ` | Cycle themes |
| `Cmd+Q` | Quit WezTerm |

## Features

- **tmux-aware keybindings** — tous les raccourcis Cmd délèguent à tmux
- **Zoom pane** — loupe dans la statusbar quand un pane est zoomé
- **Session naming** — nom de session affiché dans la statusbar
- **Claude Code notifications** — notif macOS à la fin de chaque réponse
