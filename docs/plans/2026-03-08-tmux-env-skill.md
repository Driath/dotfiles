# tmux-env Skill — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Créer un skill global `tmux-env` qui rend Claude conscient de son environnement tmux et capable de l'exploiter/améliorer, avec un `/start` invocable.

**Architecture:** Un fichier `skill.md` dans `~/.claude/skills/tmux-env/`, symlinké depuis le dotfiles pour rester reproductible. Le skill documente l'environnement (WezTerm+tmux), les commandes tmux utiles, et le réflexe de proposer des améliorations au dotfiles.

**Tech Stack:** Skill Claude Code (markdown), tmux CLI, dotfiles repo

---

### Task 1: Créer le skill dans le dotfiles

**Files:**
- Create: `skills/tmux-env/skill.md`

**Step 1: Écrire le fichier skill.md**

```markdown
---
name: tmux-env
description: "Awareness of the tmux environment. Use this skill when starting work on any project (/start), when you need to interact with other panes/windows, or when you spot a workflow that could be improved with a keybinding or script. Also triggers when the user mentions tmux, panes, windows, sessions, or terminal workflow."
user_invocable: true
user_invocable_name: start
---

# tmux-env — Terminal Environment Awareness

You are working inside a WezTerm + tmux environment. tmux manages everything: sessions, windows, panes. WezTerm is a pure renderer.

## Environment Layout

- **1 session = 1 project** (session name = project name)
- **Windows/tabs** = contextes de travail dans un projet
- **Prefix** = `Ctrl+Space`
- **macOS keybindings** (`Cmd+T`, `Cmd+W`, etc.) in WezTerm send tmux commands

## On /start — Orient Yourself

When invoked, run these commands to understand your context:

1. `tmux display-message -p '#S'` — current session (= project name)
2. `tmux list-windows -F '#I:#W'` — windows in this session
3. `tmux list-panes -F '#P:#T (#{pane_current_command})'` — panes in current window

Announce what you see: session name, windows, panes, and what seems to be running.

## Useful tmux Commands

### Reading other panes
- `tmux capture-pane -t <pane-id> -p` — read content of another pane
- `tmux capture-pane -t <pane-id> -p -S -50` — last 50 lines of a pane

### Interacting with other panes
- `tmux send-keys -t <pane-id> "command" Enter` — run command in another pane
- `tmux split-window -h` / `-v` — create new pane (horizontal/vertical)
- `tmux new-window -n "name"` — create new window

### Layout info
- `tmux list-sessions -F '#S (#{session_windows} windows)'` — all sessions
- `tmux display-message -p '#{window_width}x#{window_height}'` — current size

## Proposing Improvements

When you notice any of these patterns, **propose** (don't act) an improvement to the dotfiles:

- A workflow that requires multiple manual steps → propose a keybinding or script
- A missing IDE-like shortcut (e.g., go-to-definition, fuzzy find, etc.)
- A repetitive tmux command sequence → propose a binding in `~/.tmux.conf`
- A visual issue in the statusbar → propose a fix

**How to propose:** Say something like:
> "Ce workflow pourrait être simplifié avec un raccourci dans le dotfiles. On en parle ?"

Never modify dotfiles configs without explicit approval.

## Key Paths (dotfiles repo)

- tmux config: `~/dotfiles/tmux/.tmux.conf`
- WezTerm config: `~/dotfiles/wezterm/.config/wezterm/wezterm.lua`
- Scripts: `~/dotfiles/.local/bin/`
- Install script: `~/dotfiles/install.sh`

## Rules for Editing Configs

- **Never use `sed` or Write tool** on lines with nerd font icons — use Python binary mode
- **Always reload tmux** after config changes: `tmux source ~/.tmux.conf`
- All changes must be reproducible via `install.sh`
```

**Step 2: Vérifier que le fichier est bien formé**

Run: `head -5 skills/tmux-env/skill.md`
Expected: le frontmatter YAML avec `name: tmux-env`

**Step 3: Commit**

```bash
git add skills/tmux-env/skill.md
git commit -m "feat: add tmux-env global skill for terminal environment awareness"
```

---

### Task 2: Ajouter le symlink dans install.sh

**Files:**
- Modify: `install.sh`

**Step 1: Lire install.sh pour trouver où ajouter le symlink**

Chercher la section qui crée les symlinks existants (screenshot, statusbar, etc.)

**Step 2: Ajouter le symlink pour le skill**

Ajouter dans la section appropriée :
```bash
# Claude skills
mkdir -p "$HOME/.claude/skills"
ln -sf "$DOTFILES/skills/tmux-env" "$HOME/.claude/skills/tmux-env"
```

Si les skills screenshot et statusbar sont déjà symlinkés dans install.sh, ajouter à côté. Sinon, créer la section et ajouter les trois d'un coup.

**Step 3: Tester le symlink**

Run: `bash install.sh` (ou juste la commande ln manuellement)
Vérifier: `ls -la ~/.claude/skills/tmux-env/skill.md`

**Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add tmux-env skill symlink to install.sh"
```

---

### Task 3: Vérifier que /start fonctionne

**Step 1: Tester le skill**

Dans un nouveau chat Claude Code, taper `/start` et vérifier que :
- Le skill se charge
- Claude affiche la session, les windows, les panes
- Claude est orienté et prêt à bosser

**Step 2: Ajuster si nécessaire**

Si le skill ne trigger pas correctement, ajuster la `description` dans le frontmatter.

---

### Task 4 (optionnel): Symlinker aussi screenshot et statusbar dans install.sh

Si les skills `screenshot` et `statusbar` ne sont pas déjà dans le dotfiles repo et symlinkés via install.sh, les y ajouter pour la reproductibilité.

**Step 1: Vérifier l'état actuel**

```bash
ls -la ~/.claude/skills/screenshot
ls -la ~/.claude/skills/statusbar
```

Si ce sont déjà des symlinks vers le dotfiles → rien à faire.
Sinon → les déplacer dans `skills/` du dotfiles et symlinker.

**Step 2: Commit si changement**

```bash
git add skills/
git commit -m "feat: move screenshot and statusbar skills to dotfiles repo"
```
