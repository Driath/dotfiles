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
config.enable_tab_bar = false
config.window_background_opacity = 0.7
config.macos_window_background_blur = 0
config.window_decorations = 'RESIZE'
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

-- Cmd+click pour ouvrir les liens (hyperlinks)
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- obsidian:// links clickable (Cmd+click)
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

-- libra — chemins, path:line, sha et dossiers cliquables (Cmd+click).
-- Le module AJOUTE ses règles aux hyperlink_rules ci-dessus, il ne les écrase
-- pas : la règle obsidian:// survit. Son handler open-uri s'enregistre après
-- celui-ci, qui ne retourne false que sur obsidian — les deux cohabitent.
-- Source : ~/Projects/libra/emitters/wezterm/libra.lua
package.path = os.getenv('HOME') .. '/Projects/libra/emitters/wezterm/?.lua;' .. package.path
require('libra').apply_to_config(config)

-- Claude Code pushes its own version as the OSC title ("2.1.220"), which is
-- useless when juggling projects. Build our own: path · process · claude.
local function basename(p)
  return p:match('([^/]+)$') or p
end

-- Absolute path, ~-shortened. Returns nil when wezterm has no OSC 7 cwd.
local function pane_path(pane)
  local cwd = pane.current_working_dir
  if not cwd then return nil end

  local raw = type(cwd) == 'userdata' and cwd.file_path or tostring(cwd)
  raw = raw:gsub('^file://[^/]*', ''):gsub('(.)/$', '%1')

  local home = os.getenv('HOME')
  if home and home ~= '' and raw:sub(1, #home) == home then
    return '~' .. raw:sub(#home + 1)
  end
  return raw
end

wezterm.on('format-window-title', function(tab)
  local pane = tab.active_pane
  local parts = {}

  local path = pane_path(pane)
  if path then table.insert(parts, path) end

  -- Reports the command running in the pane
  local proc = pane.foreground_process_name
  if proc and proc ~= '' then table.insert(parts, basename(proc)) end

  -- Claude Code announces itself through the OSC title; surface it as a badge
  local osc = pane.title or ''
  local version = osc:match('^(%d+%.%d+%.%d+)$')
  if version then
    table.insert(parts, 'claude ' .. version)
  elseif osc ~= '' and osc:lower():find('claude', 1, true) then
    table.insert(parts, 'claude')
  end

  if #parts == 0 then return 'wezterm' end
  return table.concat(parts, '  ·  ')
end)

return config
