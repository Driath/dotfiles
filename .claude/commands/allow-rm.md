Ajouter une permission `rm -rf` pour un path spécifique dans `~/.claude/settings.json`.

## Arguments

`$ARGUMENTS` contient le path à autoriser (ex: `/tmp/test-bidon` ou `~/Projects/LORE/worktrees/...`).

## Process déterministe

1. Lire `~/.claude/settings.json`
2. Vérifier que la permission `Bash(rm -rf $ARGUMENTS:*)` n'est pas déjà présente
3. Si absente : l'ajouter dans le tableau `permissions.allow`
4. Confirmer à l'utilisateur ce qui a été ajouté
5. NE PAS exécuter le `rm -rf` — l'utilisateur doit le relancer explicitement
