# bawi

> "Bah oui, j'peux le faire lol"

A terminal IDE where the AI agent is a first-class citizen. Ghostty/WezTerm + tmux + Claude Code — you give the context, the agent does the rest.

## Philosophy

Traditional dotfiles configure a terminal for a human. bawi configures it for a **human-agent team**:

- **You** decide what to build, validate results, test keybindings
- **The agent** reads the screen, makes changes, verifies visually, iterates autonomously
- **The setup** bridges both — scripts the agent can call, skills so it understands what it sees, config with zero magic strings

Three layers make this work:

1. **Terminal** — Ghostty/WezTerm as pure renderer, tmux manages everything
2. **Scripts** — small composable `.sh` files in `~/.local/bin/`, all sourcing a shared config
3. **Skills** — Claude Code skills that give the agent awareness of the environment

## Install

```bash
git clone https://github.com/Driath/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then restart your terminal and run `tmux kill-server`.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Requirements

- [Ghostty](https://ghostty.org/) or [WezTerm](https://wezfurlong.org/wezterm/)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [Starship](https://starship.rs/) — `brew install starship`
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- Python 3 + pyobjc-framework-Quartz — `pip3 install pyobjc-framework-Quartz`

## Architecture

- **Ghostty/WezTerm** = pure renderer (no native tabs, no default keybindings)
- **tmux** = manages everything (sessions, windows, panes)
- **1 session = 1 project**, windows/tabs = work contexts
- macOS keybindings (`Cmd+T`, `Cmd+W`, etc.) send tmux commands
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

### Swap
| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+←/→` | Swap window left/right |
| `Cmd+Alt+Shift+←→↑↓` | Swap panes |

### Other (system)
| Shortcut | Action |
|----------|--------|
| `Cmd+C` | Copy (if selection) or Ctrl+C |
| `Cmd+V` | Paste (images saved as paths) |
| `Cmd+F` | Toggle fullscreen |
| `Cmd++/-/0` | Font size |
| `Cmd+Shift+P` | Cycle themes |
| `Cmd+,` | Open Ghostty config |
| `Cmd+M` | Speech-to-text |
| `Cmd+E` | Neo-tree (Neovim) |
| `Cmd+P` | Find files (Neovim) / fzf (shell) |
| `Cmd+Q` | Quit |

### Neovim — Navigation

The keybinding layers follow an IDE-like pattern using arrow keys with modifiers.

| Shortcut | Action | Scope |
|----------|--------|-------|
| `Arrow` | Char/line movement | Default |
| `Shift+Arrow` | Visual selection | Default |
| `Option+←/→` | Jump by word | All modes |
| `Option+↑/↓` | Jump by function (Treesitter) or paragraph (fallback) | All modes |
| `Option+Shift+←/→` | Select by word | All modes |
| `Option+Shift+↑/↓` | Select to prev/next function | All modes |
| `Ctrl+Option+←/→` | Switch buffer (tab) | All modes |

### Neovim — Editor actions

These map to macOS conventions. `Cmd+key` in Ghostty sends `Meta+key` to Neovim via Kitty protocol.

| Shortcut | Action | Notes |
|----------|--------|-------|
| `Cmd+S` | Save | via `Option+S` |
| `Cmd+Z` | Undo | via `Option+Z` |
| `Cmd+Shift+Z` | Redo | via `Option+Shift+Z` |
| `Cmd+A` | Select all | via `Option+A` |
| `Cmd+C` | Copy to clipboard | via `Option+C` (visual mode) |
| `Cmd+V` | Paste from clipboard | via `Option+V` |
| `Cmd+X` | Cut to clipboard | via `Option+X` |
| `Cmd+:` | Toggle comment | via `Option+:` (AZERTY: `/` = `Shift+:`) |
| `Option+Backspace` | Delete word backwards | Insert mode |
| `Backspace` | Delete selection | Visual mode |
| `Ctrl+Z` | Suspend Neovim | Kitty protocol fix |

## Statusbar

### Left
- Session icon + name + index/total

### Middle (windows)
- Window list with smart titles (process or path)
- Indicators: split pane `󰕮`, notification bell `󱥁`, zoom `󰍉`

### Right
- Pane CPU/RAM, STT indicator, prefix, zoom, global notifs, system CPU/RAM

### Pane borders
Each pane has a title bar showing: `●`/`○` + command + path + title + CPU/RAM stats. The pane title is the pane's live status.

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

## Agent integration

### Skills
| Skill | What it does |
|-------|-------------|
| `tmux-env` | Environment awareness — the agent knows where it is, what it sees, and how to interact with tmux |
| `screenshot` | Capture the terminal window for visual inspection |
| `statusbar` | Capture just the tmux statusbar |

### Scripts
| Script | What it does |
|--------|-------------|
| `terminal-window-id.sh` | Detect active terminal (Ghostty or WezTerm) |
| `screenshot.sh` | Capture terminal window as JPEG |
| `statusbar-capture.sh` | Capture tmux statusbar |
| `statusbar-format.sh` | Generate tmux status-left, status-right, window formats |
| `pane-border-format.sh` | Generate pane border title format |
| `pane-stats-update.sh` | Update per-pane CPU/RAM stats |
| `yazi-toggle.sh` | Toggle yazi file manager sidebar |
| `speech-to-text.sh` | Voice input via whisper-cpp |

### Config
All scripts source `~/.local/etc/terminal.conf` — no magic strings.

### Notifications
- macOS notification when Claude finishes (session/window in title, prompt + response)
- Click to focus the right tmux pane
- Bell icon on window until you switch to it

## Plugins

| Plugin | Description |
|--------|-------------|
| [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu) | CPU + RAM percentage |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions after reboot |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15 min |

## Files

| Path | Description |
|------|-------------|
| `.local/etc/terminal.conf` | Global configuration |
| `.config/ghostty/config` | Ghostty config |
| `.config/wezterm/wezterm.lua` | WezTerm config |
| `tmux/.tmux.conf` | tmux config |
| `.config/starship.toml` | Starship prompt |
| `.local/bin/` | All scripts |
| `.claude/skills/` | Claude Code skills |
| `DESIGN.md` | Design system documentation |
