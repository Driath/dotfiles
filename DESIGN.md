# Design System

## Principes

Les couleurs sont définies de façon **sémantique** dans `tmux/.tmux.conf` via des variables `@color-*`.
Elles mappent sur les **16 couleurs ANSI** — c'est WezTerm (via le thème actif) qui décide du rendu visuel réel.

Avantages :
- Changer de thème WezTerm (`Cmd+>`) adapte automatiquement toute la statusbar
- La sémantique reste cohérente peu importe le thème
- Un seul endroit pour modifier la palette

## Palette

| Token | ANSI | Sémantique | Utilisé sur |
|-------|------|------------|-------------|
| `@color-active` | `cyan` | Élément focus, actif | Session, window active, pane border active |
| `@color-accent` | `brightcyan` | Highlight, titre | Titre window active |
| `@color-inactive` | `brightblack` | Muted, unfocus | Windows inactives, heure, pane border inactive |
| `@color-text` | `white` | Texte normal | Statusbar fg |
| `@color-separator` | `black` | Séparateurs | `│`, pane border |
| `@color-warning` | `yellow` | Alerte, attention | Zoom 󰍉, cloche 󱅫 |
| `@color-success` | `green` | Succès, ok | (réservé) |
| `@color-danger` | `red` | Erreur, destructif | (réservé) |
| `@color-info` | `brightblue` | Informatif neutre | Split indicator 󰕮 |

## Les 16 couleurs ANSI

Les thèmes remappent ces 16 indices vers leurs propres valeurs hex.
`bright*` n'est pas forcément une version plus claire — chaque thème fait ses propres choix.

| Index | Nom | Bright |
|-------|-----|--------|
| 0 | `black` | `brightblack` (souvent gris) |
| 1 | `red` | `brightred` |
| 2 | `green` | `brightgreen` |
| 3 | `yellow` | `brightyellow` |
| 4 | `blue` | `brightblue` |
| 5 | `magenta` | `brightmagenta` |
| 6 | `cyan` | `brightcyan` |
| 7 | `white` | `brightwhite` |

### Exemple — Catppuccin Mocha

| ANSI | Hex | Rendu |
|------|-----|-------|
| `cyan` | `#89dceb` | teal clair |
| `brightcyan` | `#89b4fa` | bleu/lavande |
| `blue` | `#89b4fa` | bleu |
| `brightblue` | `#b4befe` | lavande |
| `yellow` | `#f9e2af` | jaune doux |
| `brightblack` | `#585b70` | gris foncé |
| `black` | `#313244` | très foncé |

## Ajouter un nouveau token

1. Ajouter dans `tmux/.tmux.conf` dans la section `# Design system`
2. Documenter dans ce fichier
3. Utiliser via `#[fg=#{@color-montoken}]` dans les formats tmux
