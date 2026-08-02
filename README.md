# bawi

> "Bah oui, j'peux le faire lol"

A terminal IDE where the AI agent is a first-class citizen. Ghostty/WezTerm + Claude Code — you give the context, the agent does the rest.

## Philosophy

Traditional dotfiles configure a terminal for a human. bawi configures it for a **human-agent team**:

- **You** decide what to build, validate results, test keybindings
- **The agent** reads the screen, makes changes, verifies visually, iterates autonomously
- **The setup** bridges both — scripts the agent can call, skills so it understands what it sees, config with zero magic strings

Three layers make this work:

1. **Terminal** — Ghostty/WezTerm as renderer, native tabs and panes
2. **Scripts** — small composable `.sh` files in `~/.local/bin/`, all sourcing a shared config
3. **Skills** — Claude Code skills that give the agent awareness of the environment

## Install

```bash
git clone https://github.com/Driath/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then restart your terminal.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Requirements

- [Ghostty](https://ghostty.org/) or [WezTerm](https://wezfurlong.org/wezterm/)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [Starship](https://starship.rs/) — `brew install starship`
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- Python 3 + pyobjc-framework-Quartz — `pip3 install pyobjc-framework-Quartz`

## Architecture

- **Ghostty/WezTerm** = renderer, native tabs/windows/panes
- macOS keybindings (`Cmd+T`, `Cmd+W`, etc.) map to native terminal actions

## Keybindings

### Windows / tabs
| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New tab |
| `Cmd+W` | Close window |
| `Cmd+←/→` | Navigate tabs |
| `Cmd+&/é/"/'/'(' | Jump to tab 1-5 (AZERTY) |

### Panes
| Shortcut | Action |
|----------|--------|
| `Cmd+D` | Split horizontal |
| `Cmd+Shift+D` | Split vertical |
| `Cmd+Alt+←→↑↓` | Navigate panes |
| `Cmd+Alt+Shift+←→↑↓` | Resize panes |
| `Cmd+Alt+F` | Zoom pane (toggle) |

### Other (system)
| Shortcut | Action |
|----------|--------|
| `Cmd+C` | Copy (if selection) or Ctrl+C |
| `Cmd+V` | Paste (images saved as paths) |
| `Cmd+F` | Toggle fullscreen |
| `Cmd++/-/0` | Font size |
| `Cmd+Shift+L/K` | Cycle themes (WezTerm) |
| `Cmd+Shift+I/O` | Cycle fonts (WezTerm) |
| `Cmd+Shift+U/J` | Cycle opacity (WezTerm) |
| `Cmd+,` | Open config |
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

## Agent integration

### Skills
| Skill | What it does |
|-------|-------------|
| `screenshot` | Capture the terminal window for visual inspection |

### Scripts
| Script | What it does |
|--------|-------------|
| `terminal-window-id.sh` | Detect active terminal (Ghostty or WezTerm) |
| `screenshot.sh` | Capture terminal window as JPEG |

### Config
All scripts source `~/.local/etc/terminal.conf` — no magic strings.

### Notifications
- macOS notification when Claude finishes (session/window in title, prompt + response)

## Files

| Path | Description |
|------|-------------|
| `.local/etc/terminal.conf` | Global configuration |
| `.config/ghostty/config` | Ghostty config |
| `.config/wezterm/wezterm.lua` | WezTerm config |
| `.config/starship.toml` | Starship prompt |
| `.local/bin/` | All scripts |
| `.claude/skills/` | Claude Code skills |
