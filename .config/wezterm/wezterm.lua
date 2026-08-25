local wezterm = require 'wezterm'
local HOME = os.getenv('HOME')

-- Find binary path
local function find_bin(name, fallback)
  local h = io.popen('command -v ' .. name .. ' 2>/dev/null')
  if h then
    local path = h:read('*l')
    h:close()
    if path and path ~= '' then return path end
  end
  return fallback
end

local notifier_bin = find_bin('terminal-notifier', '/opt/homebrew/bin/terminal-notifier')

-- Cycle de thèmes
local fonts = {
  'GeistMono Nerd Font',
  'Hack Nerd Font',
  'FiraCode Nerd Font',
  'JetBrainsMono Nerd Font',
  'CommitMono Nerd Font',
  'MesloLGS Nerd Font',
  'SauceCodePro Nerd Font',
  'Inconsolata Nerd Font',
  'JetBrains Mono',
  'BlexMono Nerd Font',
  'VictorMono Nerd Font',
  'Iosevka Nerd Font',
  'Maple Mono NF',
}

local font_file = '/tmp/wezterm_font_index'

local function get_font_index()
  local f = io.open(font_file, 'r')
  if not f then return 1 end
  local n = tonumber(f:read('*l')) or 1
  f:close()
  return n
end

local function set_font_index(n)
  local f = io.open(font_file, 'w')
  if f then f:write(tostring(n)); f:close() end
end

local function cycle_font(window, delta)
  local idx = get_font_index()
  idx = ((idx - 1 + delta) % #fonts) + 1
  set_font_index(idx)
  window:set_config_overrides({ font = wezterm.font(fonts[idx]) })
  io.popen(notifier_bin .. ' -title "Font" -message "' .. fonts[idx] .. '" -group wezterm')
end

local opacity_file = '/tmp/wezterm_opacity'

local function get_opacity()
  local f = io.open(opacity_file, 'r')
  if not f then return 0.7 end
  local n = tonumber(f:read('*l')) or 0.7
  f:close()
  return n
end

local function set_opacity(n)
  local f = io.open(opacity_file, 'w')
  if f then f:write(tostring(n)); f:close() end
end

local function cycle_opacity(window, delta)
  local v = get_opacity()
  v = math.max(0.1, math.min(1.0, v + delta))
  v = math.floor(v * 100 + 0.5) / 100
  set_opacity(v)
  window:set_config_overrides({ window_background_opacity = v })
  io.popen(notifier_bin .. ' -title "Opacity" -message "' .. tostring(v) .. '" -group wezterm')
end

local themes = {
  'Catppuccin Mocha',
  'Tokyo Night',
  'Dracula',
  'Nord (Gogh)',
  'Gruvbox Dark',
  'One Dark (Gogh)',
  'Kanagawa (Gogh)',
  'rose-pine',
  'Cobalt2',
}

local theme_file = '/tmp/wezterm_theme_index'

local function get_theme_index()
  local f = io.open(theme_file, 'r')
  if not f then return 1 end
  local n = tonumber(f:read('*l')) or 1
  f:close()
  return n
end

local function set_theme_index(n)
  local f = io.open(theme_file, 'w')
  if f then f:write(tostring(n)); f:close() end
end

local function cycle_theme(window, delta)
  local idx = get_theme_index()
  idx = ((idx - 1 + delta) % #themes) + 1
  set_theme_index(idx)
  window:set_config_overrides({ color_scheme = themes[idx] })
  io.popen(notifier_bin .. ' -title "Theme" -message "' .. themes[idx] .. '" -group wezterm')
end

local config = wezterm.config_builder()

-- Shell direct, sans tmux, toujours dans ~/
config.default_prog = { '/bin/zsh', '-l' }
config.default_cwd = wezterm.home_dir

-- Apparence
-- config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
  'Symbols Nerd Font Mono',
  -- Le fallback système s'arrête sur Apple SD Gothic Neo (coréenne) : elle a
  -- 中/文 mais pas les formes simplifiées 简/体, d'où les .notdef. Hiragino
  -- Sans GB couvre le chinois simplifié, Hiragino Sans le japonais.
  -- (PingFang n'est pas utilisable : PingFangUI.ttc est réservée à l'UI et
  -- n'apparaît pas dans `wezterm ls-fonts --list-system`.)
  'Hiragino Sans GB',
  'Hiragino Sans',
  'Apple Color Emoji',
}
config.font_size = 14
config.line_height = 1.05
config.front_end = 'WebGpu'
config.enable_kitty_graphics = true
config.window_padding = { left = '1cell', right = '1cell', top = '0.5cell', bottom = '0.5cell' }
config.enable_tab_bar = true
-- La fancy tab bar colle un bouton ✕ sur chaque onglet, que rien ne
-- configure : même avec un libellé vide (cf. format-tab-title), le ✕ reste à
-- côté des trois boutons. Seule la retro (false) s'en débarrasse, mais son
-- rendu en cellules terminal est moins bon. On garde fancy, on garde le ✕.
config.use_fancy_tab_bar = true
-- Les deux false sont imposés par INTEGRATED_BUTTONS (cf. window_decorations
-- plus bas) : les boutons natifs sont dessinés DANS la barre d'onglets. Si
-- elle se cache à un seul onglet, les boutons partent avec ; si elle est en
-- bas, ils descendent avec.
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
-- Le bouton + ferme la boucle du minimalisme : pas de bouton, pas de liseré
-- à styliser à côté. Cmd+T (déjà bindé) ouvre un onglet.
config.show_new_tab_button_in_tab_bar = false
-- window_frame gère la vraie transparence (blend correct avec le bureau,
-- comme le pane). Les bg_color par onglet (ci-dessous) créaient une couche
-- composée par-dessus qui ne blendait pas pareil → pastille visiblement
-- opaque même à 0.7. Donc alpha ici, et aucun bg_color sur les onglets.
config.window_frame = {
  -- Base fine, l'onglet actif ressort via Attribute.Intensity='Bold' dans
  -- format-tab-title (synthétisé par-dessus si la famille n'a pas de vrai
  -- style Bold distinct).
  font = wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Light' },
  active_titlebar_bg = 'rgba(17, 17, 27, 0.7)',
  inactive_titlebar_bg = 'rgba(17, 17, 27, 0.7)',
}
-- bg_color est un champ obligatoire du schéma (WezTerm refuse de l'omettre),
-- mais alpha 0 = couche invisible : l'onglet repose sur le fond (déjà
-- transparent) du window_frame ci-dessus, sans jamais assombrir en le
-- superposant. Seule l'épaisseur de la police distingue l'onglet actif
-- (Bold) du reste (Normal).
config.colors = {
  background = '#11111b',
  tab_bar = {
    -- window_frame peint la barre en fancy. Ce champ est la reprise si on
    -- repasse en retro. Alpha safe ici vu que active_tab/inactive_tab sont
    -- eux-mêmes à alpha 0 (pas de cumul).
    background = 'rgba(17, 17, 27, 0.7)',
    -- fg_color est ici pour satisfaire le schéma (champ obligatoire comme
    -- bg_color) mais sans effet réel : format-tab-title ci-dessous fixe sa
    -- propre couleur par segment (path/branche/titre) et l'emporte toujours.
    active_tab = { bg_color = 'rgba(17, 17, 27, 0)', fg_color = '#ffffff' },
    inactive_tab = { bg_color = 'rgba(17, 17, 27, 0)', fg_color = '#a0a0a0' },
    inactive_tab_hover = { bg_color = 'rgba(17, 17, 27, 0)', fg_color = '#ffffff' },
    -- Tentative : ce champ est documenté "retro tab bar only" par WezTerm,
    -- peut-être sans effet ici. Si le séparateur entre onglets reste visible
    -- après reload, c'est un artefact de rendu (seam d'antialiasing sur deux
    -- quads adjacents à bg_color alpha 0), pas un champ manquant à trouver.
    inactive_tab_edge = '#11111b',
  },
}
config.window_background_opacity = 0.7
config.macos_window_background_blur = 0
-- INTEGRATED_BUTTONS = WezTerm dessine lui-même les trois boutons dans la
-- barre d'onglets, au lieu d'une barre de titre native. C'est la seule façon
-- d'avoir un fond transparent derrière eux : la barre native est peinte par
-- macOS et ignore active_titlebar_bg, INTEGRATED_BUTTONS le respecte.
config.window_decorations = 'INTEGRATED_BUTTONS | RESIZE'
config.integrated_title_button_style = 'MacOsNative'
config.integrated_title_button_alignment = 'Left'
config.window_close_confirmation = 'NeverPrompt'
-- true = fullscreen natif macOS : Space dédié, menu bar cachée (reveal au
-- survol), contenu sous la safe-area donc 38 pt de bande notch noircie.
config.native_macos_fullscreen_mode = true
config.enable_kitty_keyboard = true
config.text_background_opacity = 0.2

-- Left option compose (AZERTY : \, |, @, etc.)
config.send_composed_key_when_left_alt_is_pressed = true

-- Désactive tous les keybindings par défaut de WezTerm
config.disable_default_key_bindings = true

config.keys = {
  -- Cmd+T : nouvel onglet WezTerm natif
  { key = 't', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  -- Cmd+W : ferme le pane WezTerm natif (sans confirmation)
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  -- Cmd+1..5 : onglets natifs (AZERTY)
  { key = '&', mods = 'CMD', action = wezterm.action.ActivateTab(0) },
  { key = 'é', mods = 'CMD', action = wezterm.action.ActivateTab(1) },
  { key = '"', mods = 'CMD', action = wezterm.action.ActivateTab(2) },
  { key = "'", mods = 'CMD', action = wezterm.action.ActivateTab(3) },
  { key = '(', mods = 'CMD', action = wezterm.action.ActivateTab(4) },
  -- Cmd+Shift+R : recharge la config. `disable_default_key_bindings = true`
  -- retire le binding par défaut, donc il n'existait plus du tout.
  { key = 'r', mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration },
  -- Cmd+, : ouvre la config
  { key = ',', mods = 'CMD', action = wezterm.action.SpawnCommandInNewTab {
    args = { '/bin/zsh', '-c', 'open ' .. (HOME or '') .. '/.config/wezterm/wezterm.lua' },
  }},
  -- Cmd+C : copier si sélection, sinon SIGINT
  { key = 'c', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    local has_selection = window:get_selection_text_for_pane(pane) ~= ''
    if has_selection then
      window:perform_action(wezterm.action.CopyTo 'Clipboard', pane)
    else
      window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
    end
  end)},
  -- Cmd+V : coller (image → path, texte → texte)
  { key = 'v', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    local paste_script = (HOME or '') .. '/.local/share/wezterm/clipboard-paste.sh'
    local handle = io.popen(paste_script)
    if not handle then
      window:perform_action(wezterm.action.PasteFrom 'Clipboard', pane)
      return
    end
    local result = handle:read('*a')
    handle:close()
    if result and result ~= '' then
      window:perform_action(wezterm.action.SendString(result), pane)
    end
  end)},
  -- Cmd+Option+Shift+Arrows : redimensionner le pane natif
  { key = 'LeftArrow',  mods = 'CMD|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 3 } },
  { key = 'RightArrow', mods = 'CMD|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 3 } },
  { key = 'UpArrow',    mods = 'CMD|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 3 } },
  { key = 'DownArrow',  mods = 'CMD|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 3 } },
  -- Cmd+Option+Arrows : naviguer entre panes natifs
  { key = 'LeftArrow',  mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  -- Cmd+R : recharger la config (binding natif, cf. Cmd+Shift+R ci-dessous)
  -- Cmd+F : plein écran
  { key = 'f', mods = 'CMD', action = wezterm.action.ToggleFullScreen },
  -- Cmd+Alt+F : zoom/dézoom pane natif
  { key = 'f', mods = 'CMD|ALT', action = wezterm.action.TogglePaneZoomState },
  -- Cmd+D : split horizontal (gauche|droite) / Cmd+Shift+D : split vertical (haut/bas)
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- Cmd+N : nouvelle fenêtre WezTerm
  { key = 'n', mods = 'CMD', action = wezterm.action.SpawnWindow },
  -- Cmd+Shift+N : nouvelle fenêtre WezTerm
  { key = 'n', mods = 'CMD|SHIFT', action = wezterm.action.SpawnWindow },
  -- Cmd+Shift+R : recharger la config
  -- Cmd+Left/Right : naviguer entre onglets
  { key = 'LeftArrow', mods = 'CMD', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.ActivateTabRelative(1) },
  -- Cmd+Shift+Left/Right : déplacer l'onglet
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = wezterm.action.MoveTabRelative(1) },
  -- Cmd+Shift+L / Cmd+Shift+K : cycle thèmes
  { key = 'l', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_theme(window, 1) end) },
  { key = 'k', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_theme(window, -1) end) },
  -- Cmd+Shift+I / Cmd+Shift+O : cycle fonts
  { key = 'i', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_font(window, 1) end) },
  { key = 'o', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_font(window, -1) end) },
  -- Cmd+Shift+U / Cmd+Shift+J : opacity +/-
  { key = 'u', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_opacity(window, 0.05) end) },
  { key = 'j', mods = 'CMD|SHIFT', action = wezterm.action_callback(function(window) cycle_opacity(window, -0.05) end) },
  -- Ctrl+Shift+L : debug overlay (logs)
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay },
  -- Cmd+Q : ferme WezTerm
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication },
  -- Cmd++ / Cmd+- / Cmd+0 : zoom
  { key = '+', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  -- Cmd+F : natif macOS (pas de binding WezTerm)
  -- Shift+Enter
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
  -- Cmd → Meta pour Neovim
  { key = 's', mods = 'CMD', action = wezterm.action.SendString('\x1bs') },
  { key = 'z', mods = 'CMD', action = wezterm.action.SendString('\x1bz') },
  { key = 'z', mods = 'CMD|SHIFT', action = wezterm.action.SendString('\x1bZ') },
  { key = 'a', mods = 'CMD', action = wezterm.action.SendString('\x1ba') },
  { key = 'x', mods = 'CMD', action = wezterm.action.SendString('\x1bx') },
  { key = ':', mods = 'CMD', action = wezterm.action.SendString('\x1b:') },
  -- Cmd+P : find files (Neovim) / fzf (shell)
  { key = 'p', mods = 'CMD', action = wezterm.action.SendString('\x1bp') },
  -- Cmd+Shift+P : rien (theme cycling déjà sur Cmd+Shift+L/K)
  -- Cmd+Shift+T : nouvel onglet
  { key = 't', mods = 'CMD|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  -- Fix Option+Arrow (CSI sequences)
  { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.SendString('\x1b[1;3D') },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.SendString('\x1b[1;3C') },
  { key = 'UpArrow', mods = 'ALT', action = wezterm.action.SendString('\x1b[1;3A') },
  { key = 'DownArrow', mods = 'ALT', action = wezterm.action.SendString('\x1b[1;3B') },
  -- Fix Ctrl+Option+Arrow (CSI modifier 7 = Ctrl+Alt)
  { key = 'LeftArrow', mods = 'CTRL|ALT', action = wezterm.action.SendString('\x1b[1;7D') },
  { key = 'RightArrow', mods = 'CTRL|ALT', action = wezterm.action.SendString('\x1b[1;7C') },
}

-- Option+click pour ouvrir les liens (hyperlinks) — geste unique, aligné sur la
-- philosophie « coup d'œil » (libra). MESURÉ (wezterm show-keys) : les défauts
-- restent actifs pour tout combo (event, mods) non redéfini ici — Up sans
-- modificateur, SHIFT et SHIFT|ALT ouvraient donc ENCORE le lien via
-- CompleteSelectionOrOpenLinkAtMouseCursor. On les rabat sur CompleteSelection
-- (la copie au relâchement survit, l'ouverture de lien tombe).
-- ALT en Or-, pas OpenLink sec : sinon alt+drag (sélection rectangulaire) ne
-- copie plus rien au relâchement — le Up ALT est le même événement.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SHIFT|ALT',
    action = wezterm.action.CompleteSelection 'PrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
  },
}

-- obsidian:// links clickable (option+click)
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[obsidian://[^\s"'<>]+]],
  format = '$0',
})

wezterm.on('open-uri', function(window, pane, uri)
  wezterm.log_error('open-uri called: ' .. uri)
  if uri:find('obsidian://', 1, true) == 1 then
    wezterm.run_child_process({ 'open', uri })
    return false
  end
end)

-- libra — chemins, path:line, sha et dossiers cliquables (option+click).
-- Le module AJOUTE ses règles aux hyperlink_rules ci-dessus, il ne les écrase
-- pas : la règle obsidian:// survit. Son handler open-uri s'enregistre après
-- celui-ci, qui ne retourne false que sur obsidian — les deux cohabitent.
-- Source : ~/Projects/libra/emitters/wezterm/libra.lua
package.path = os.getenv('HOME') .. '/Projects/libra/emitters/wezterm/?.lua;' .. package.path
require('libra').apply_to_config(config)

-- Absolute cwd, non transformé. Returns nil when wezterm has no OSC 7 cwd.
local function pane_cwd(pane)
  local cwd = pane.current_working_dir
  if not cwd then return nil end

  local raw = type(cwd) == 'userdata' and cwd.file_path or tostring(cwd)
  return (raw:gsub('^file://[^/]*', ''):gsub('(.)/$', '%1'))
end

-- Absolute path, ~-shortened.
local function pane_path(pane)
  local raw = pane_cwd(pane)
  if not raw then return nil end

  local home = os.getenv('HOME')
  if home and home ~= '' and raw:sub(1, #home) == home then
    return '~' .. raw:sub(#home + 1)
  end
  return raw
end

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Un seul `git status` fait tout (branche, ahead/behind, fichiers modifiés) —
-- mis en cache car format-tab-title tourne trop souvent pour se permettre un
-- subprocess à chaque appel. git gère lui-même la remontée depuis un
-- sous-dossier ou un worktree, pas besoin de le refaire à la main.
local git_cache = {}
local GIT_CACHE_TTL = 3

local function git_status(dir)
  if not dir then return nil end

  local cached = git_cache[dir]
  local now = os.time()
  if cached and (now - cached.time) < GIT_CACHE_TTL then
    return cached.data
  end

  local handle = io.popen('git -C ' .. shell_quote(dir) .. ' status --porcelain=v2 --branch 2>/dev/null')
  local output = handle and handle:read('*a')
  if handle then handle:close() end

  local data = nil
  if output and output ~= '' then
    local branch = output:match('# branch%.head (%S+)')
    local oid = output:match('# branch%.oid (%x+)')
    local ahead, behind = output:match('# branch%.ab %+(%d+) %-(%d+)')
    local dirty = 0
    for line in output:gmatch('[^\n]+') do
      local tag = line:sub(1, 1)
      if tag == '1' or tag == '2' or tag == 'u' or tag == '?' then
        dirty = dirty + 1
      end
    end
    data = {
      branch = (branch and branch ~= '(detached)') and branch or (oid and oid:sub(1, 7)),
      dirty = dirty,
      ahead = tonumber(ahead) or 0,
      behind = tonumber(behind) or 0,
    }
  end

  git_cache[dir] = { time = now, data = data }
  return data
end

-- Une couleur par nature de segment (Catppuccin Mocha) : on distingue
-- path/branche/titre/statut au coup d'œil, indépendamment du focus de l'onglet.
local SEGMENT_COLORS = {
  path = '#89dceb',
  branch = '#cba6f7',
  title = '#a6e3a1',
  dirty = '#f9e2af',
  ahead = '#a6e3a1',
  behind = '#f38ba8',
}

-- Un sous-segment par couleur : branche (mauve), *N modifiés (jaune, alerte
-- douce), ↑N à pousser (vert), ↓N à tirer (rouge) — pas un seul bloc mauve.
local function git_segments(status)
  if not status or not status.branch then return {} end
  local segs = { { text = '\u{f418} ' .. status.branch, color = SEGMENT_COLORS.branch } }
  if status.dirty > 0 then
    table.insert(segs, { text = ' *' .. status.dirty, color = SEGMENT_COLORS.dirty })
  end
  if status.ahead > 0 then
    table.insert(segs, { text = ' ↑' .. status.ahead, color = SEGMENT_COLORS.ahead })
  end
  if status.behind > 0 then
    table.insert(segs, { text = ' ↓' .. status.behind, color = SEGMENT_COLORS.behind })
  end
  return segs
end

-- Style fish/starship : chaque segment sauf le dernier réduit à 1 char (2
-- pour un dossier caché, point compris). "~/Projects/czeski.fr" -> "~/P/czeski.fr".
local function shorten_path(path)
  local leading_slash = path:sub(1, 1) == '/' and '/' or ''
  local segments = {}
  for seg in path:gmatch('[^/]+') do
    table.insert(segments, seg)
  end
  for i = 1, #segments - 1 do
    local seg = segments[i]
    segments[i] = seg:sub(1, 1) == '.' and seg:sub(1, 2) or seg:sub(1, 1)
  end
  return leading_slash .. table.concat(segments, '/')
end

-- path (brut ou raccourci selon path_transform) · branche git (+ sous-segments
-- statut) · titre du pane. Chaque élément de la liste retournée est un GROUPE
-- (liste de {text, color}) : ' · ' ne sépare qu'entre groupes, jamais entre
-- les sous-segments d'un même groupe (branche/*N/↑N/↓N restent collés).
-- pane.title est déjà le meilleur signal dispo (OSC 2 mis à jour par le
-- process qui tourne dedans — Claude Code y pousse son titre de tâche/
-- branche, sinon WezTerm y met le nom du process par défaut) : pas besoin de
-- le reparser. Partagé par format-tab-title et format-window-title.
local function pane_title_parts(pane, path_transform)
  local groups = {}

  local path = pane_path(pane)
  if path then
    -- nf-fa-folder
    local text = '\u{f07b} ' .. (path_transform and path_transform(path) or path)
    table.insert(groups, { { text = text, color = SEGMENT_COLORS.path } })
  end

  local git_group = git_segments(git_status(pane_cwd(pane)))
  if #git_group > 0 then table.insert(groups, git_group) end

  if pane.title and pane.title ~= '' then
    -- nf-oct-terminal
    table.insert(groups, { { text = '\u{f489} ' .. pane.title, color = SEGMENT_COLORS.title } })
  end

  return groups
end

wezterm.on('format-tab-title', function(tab, tabs)
  -- À un seul onglet, le libellé ne distingue rien : il double le contexte
  -- déjà affiché par le prompt. On rend la barre vide pour ne laisser que les
  -- trois boutons intégrés. Dès le deuxième onglet, les libellés reviennent.
  if #tabs == 1 then return '' end

  local groups = pane_title_parts(tab.active_pane, shorten_path)
  -- Séparateurs discrets, jamais dans les couleurs des segments : ils ne
  -- doivent pas concurrencer path/branche/titre pour l'attention.
  local sep_color = tab.is_active and '#9399b2' or '#585b70'

  local items = { { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } } }
  local function push(color, text)
    table.insert(items, { Foreground = { Color = color } })
    table.insert(items, { Text = text })
  end

  -- Le numéro matche les bindings Cmd+1..5 (ActivateTab(0..4) sur AZERTY).
  push(sep_color, ' ' .. (tab.tab_index + 1) .. ' · ')

  if #groups == 0 then
    push('#ffffff', 'wezterm')
  else
    for gi, group in ipairs(groups) do
      if gi > 1 then push(sep_color, ' · ') end
      for _, part in ipairs(group) do push(part.color, part.text) end
    end
  end

  table.insert(items, { Text = ' ' })
  return items
end)

wezterm.on('format-window-title', function(tab)
  local groups = pane_title_parts(tab.active_pane, nil)
  if #groups == 0 then return 'wezterm' end
  local group_texts = {}
  for _, group in ipairs(groups) do
    local buf = {}
    for _, part in ipairs(group) do table.insert(buf, part.text) end
    table.insert(group_texts, table.concat(buf))
  end
  return table.concat(group_texts, '  ·  ')
end)

return config
