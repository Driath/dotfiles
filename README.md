# dotfiles

WezTerm + tmux setup for macOS — a terminal IDE with ergonomic keybindings, smart statusbar, and Claude Code integration.

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) — `brew install terminal-notifier`
- [tpm](https://github.com/tmux-plugins/tpm) — `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- [Starship](https://starship.rs/) — `brew install starship`
- [pngpaste](https://github.com/jcsalterego/pngpaste) — `brew install pngpaste`
- Python 3 + pyobjc-framework-Quartz — `pip3 install pyobjc-framework-Quartz`

## Install

```bash
git clone https://github.com/Driath/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then restart WezTerm and run `tmux kill-server`.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Architecture

- **WezTerm** = pure renderer (no native tabs, no default keybindings)
- **tmux** = manages everything (sessions, windows, panes)
- macOS keybindings (`Cmd+T`, `Cmd+W`, etc.) in WezTerm send tmux commands
- tmux prefix = `Ctrl+Space`

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
| `Cmd+&/é/"/'/(' | Jump to window 1-5 (AZERTY) |

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
| `Cmd+V` | Paste (images saved as paths) |
| `Cmd+F` | Toggle fullscreen |
| `Cmd++/-/0` | Font size |
| `Cmd+</>` | Cycle themes |
| `Cmd+Q` | Quit WezTerm |

## Statusbar

### Left
- Session icon + name + index/total
- Window list with smart titles (process or path)
- Indicators: split pane, notification bell, zoom

### Right
- Online status
- Battery icon + percentage
- CPU percentage
- RAM percentage
- Date + time

### Design system
Semantic color palette using ANSI colors (theme-independent):

| Token | Color | Usage |
|-------|-------|-------|
| `@color-active` | cyan | Focused elements |
| `@color-inactive` | brightblack | Unfocused elements |
| `@color-text` | white | Default text |
| `@color-separator` | black | Separators |
| `@color-warning` | yellow | Zoom, prefix, notifications |
| `@color-success` | green | Online, battery charged |
| `@color-danger` | red | Offline, low battery |
| `@color-info` | brightblue | Split indicator |
| `@color-accent` | brightcyan | Accent elements |

## Plugins

| Plugin | Description |
|--------|-------------|
| [tmux-battery](https://github.com/tmux-plugins/tmux-battery) | Battery percentage + icon |
| [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu) | CPU + RAM percentage |
| [tmux-online-status](https://github.com/tmux-plugins/tmux-online-status) | Network connectivity indicator |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions after reboot |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15 min |

## Claude Code integration

- **Stop notifications** — macOS notification when Claude finishes (title: session/window, subtitle: your prompt, message: Claude's response)
- **Click to focus** — clicking the notification switches to the correct tmux session/window/pane
- **Notification bell** — bell icon on tmux window until you switch to it
- **Skills** — `/screenshot` and `/statusbar` for visual debugging

## Files

| Path | Description |
|------|-------------|
| `.config/wezterm/wezterm.lua` | WezTerm config |
| `tmux/.tmux.conf` | tmux config |
| `.config/starship.toml` | Starship prompt |
| `.local/share/wezterm/clipboard-paste.sh` | Smart paste (image/text) |
| `.local/share/claude/notify-done.sh` | Claude Code Stop hook |
| `.local/bin/screenshot.sh` | WezTerm screenshot tool |
| `.claude/skills/` | Claude Code skills |
| `DESIGN.md` | Design system documentation |
