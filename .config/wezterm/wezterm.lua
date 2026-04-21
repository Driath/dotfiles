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

local tmux_bin = find_bin('tmux', '/opt/homebrew/bin/tmux')
local notifier_bin = find_bin('terminal-notifier', '/opt/homebrew/bin/terminal-notifier')

-- Returns true if we're inside a tmux session
local function in_tmux()
  local handle = io.popen(tmux_bin .. ' info 2>/dev/null')
  if not handle then return false end
  local result = handle:read('*l')
  handle:close()
  return result ~= nil
end

-- Send tmux prefix (Ctrl+Space) + key
local function tmux(key)
  return wezterm.action.SendString("\x00" .. key)
end

-- Refresh tmux status bar
local function tmux_refresh()
  io.popen(tmux_bin .. ' refresh-client -S')
end

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

-- Démarre toujours dans tmux
config.default_prog = { '/bin/zsh', '-c', tmux_bin .. ' new-session' }

-- Apparence
-- config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 14
config.line_height = 1.05
config.front_end = 'WebGpu'
config.enable_kitty_graphics = true
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_tab_bar = false
config.window_background_opacity = 0.7
config.macos_window_background_blur = 0
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'
config.native_macos_fullscreen_mode = true
config.enable_kitty_keyboard = true
config.text_background_opacity = 0.2

-- Left option compose (AZERTY : \, |, @, etc.)
config.send_composed_key_when_left_alt_is_pressed = true

-- Désactive tous les keybindings par défaut de WezTerm
config.disable_default_key_bindings = true

-- Keybindings tmux-aware
config.keys = {
  -- Cmd+T : nouvelle window tmux (direct, sans condition)
  { key = 't', mods = 'CMD', action = tmux('c') },
  -- Cmd+W : ferme la window tmux (sans confirmation)
  { key = 'w', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    if in_tmux() then
      window:perform_action(wezterm.action.SendString("\x00x"), pane)
    else
      window:perform_action(wezterm.action.CloseCurrentPane { confirm = false }, pane)
    end
  end)},
  -- Raccourcis onglets AZERTY (naviguent entre windows tmux)
  { key = '&', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    window:perform_action(tmux('1'), pane)
  end)},
  { key = 'é', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    window:perform_action(tmux('2'), pane)
  end)},
  { key = '"', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    window:perform_action(tmux('3'), pane)
  end)},
  { key = "'", mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    window:perform_action(tmux('4'), pane)
  end)},
  { key = '(', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    window:perform_action(tmux('5'), pane)
  end)},
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
  -- Cmd+Option+Shift+Arrows : swap pane
  { key = 'LeftArrow',  mods = 'CMD|ALT|SHIFT', action = tmux('<') },
  { key = 'RightArrow', mods = 'CMD|ALT|SHIFT', action = tmux('>') },
  { key = 'UpArrow',    mods = 'CMD|ALT|SHIFT', action = tmux('+') },
  { key = 'DownArrow',  mods = 'CMD|ALT|SHIFT', action = tmux('_') },
  -- Cmd+Option+Arrows : naviguer entre panes tmux
  { key = 'LeftArrow',  mods = 'CMD|ALT', action = tmux('h') },
  { key = 'RightArrow', mods = 'CMD|ALT', action = tmux('l') },
  { key = 'UpArrow',    mods = 'CMD|ALT', action = tmux('k') },
  { key = 'DownArrow',  mods = 'CMD|ALT', action = tmux('j') },
  -- Cmd+R : renommer la session tmux
  { key = 'r', mods = 'CMD', action = tmux('S') },
  -- Cmd+Alt+F : zoom/dézoom pane tmux
  { key = 'f', mods = 'CMD|ALT', action = tmux('z') },
  -- Cmd+D : split horizontal / Cmd+Shift+D : split vertical
  { key = 'd', mods = 'CMD', action = tmux('\\') },
  { key = 'd', mods = 'CMD|SHIFT', action = tmux("'") },
  -- Cmd+N : nouvelle session tmux
  { key = 'n', mods = 'CMD', action = wezterm.action.SendString('\x1b[927~') },
  -- Cmd+Shift+N : nouvelle fenêtre WezTerm (nouvelle session tmux)
  { key = 'n', mods = 'CMD|SHIFT', action = wezterm.action.SpawnWindow },
  -- Cmd+Shift+X : supprimer si yazi
  { key = 'x', mods = 'CMD|SHIFT', action = tmux('X') },
  -- Cmd+Shift+R : renommer si yazi
  { key = 'r', mods = 'CMD|SHIFT', action = tmux('B') },
  -- Cmd+Shift+E : edit si yazi
  { key = 'e', mods = 'CMD|SHIFT', action = tmux('O') },
  -- Cmd+Up/Down : naviguer entre sessions tmux
  { key = 'UpArrow', mods = 'CMD', action = tmux('(') },
  { key = 'DownArrow', mods = 'CMD', action = tmux(')') },
  -- Cmd+Left/Right : naviguer entre windows tmux
  { key = 'LeftArrow', mods = 'CMD', action = wezterm.action.SendString('\x1b[902~') },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.SendString('\x1b[903~') },
  -- Cmd+Shift+Left/Right : swap windows
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = tmux('{') },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = tmux('}') },
  -- Cmd+Shift+Up/Down : move window to prev/next session
  { key = 'UpArrow', mods = 'CMD|SHIFT', action = tmux('B') },
  { key = 'DownArrow', mods = 'CMD|SHIFT', action = tmux('F') },
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
  -- Cmd+Q : ferme WezTerm sans toucher aux sessions tmux
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication },
  -- Cmd++ / Cmd+- / Cmd+0 : zoom
  { key = '+', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  -- Cmd+F : natif macOS (pas de binding WezTerm)
  -- Shift+Enter
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
  -- Cmd+E : toggle yazi sidebar
  { key = 'e', mods = 'CMD', action = tmux('E') },
  -- Cmd+M : speech-to-text toggle (record / stop+transcribe)
  { key = 'm', mods = 'CMD', action = tmux('m') },
  -- Cmd → Meta pour Neovim (via tmux kitty-keys)
  { key = 's', mods = 'CMD', action = wezterm.action.SendString('\x1bs') },
  { key = 'z', mods = 'CMD', action = wezterm.action.SendString('\x1bz') },
  { key = 'z', mods = 'CMD|SHIFT', action = wezterm.action.SendString('\x1bZ') },
  { key = 'a', mods = 'CMD', action = wezterm.action.SendString('\x1ba') },
  { key = 'x', mods = 'CMD', action = wezterm.action.SendString('\x1bx') },
  { key = ':', mods = 'CMD', action = wezterm.action.SendString('\x1b:') },
  -- Cmd+P : find files (Neovim) / fzf (shell)
  { key = 'p', mods = 'CMD', action = wezterm.action.SendString('\x1bp') },
  -- Cmd+Shift+P : theme cycling tmux
  { key = 'p', mods = 'CMD|SHIFT', action = tmux('G') },
  -- Cmd+Shift+T : new window in yazi dir
  { key = 't', mods = 'CMD|SHIFT', action = tmux('T') },
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

return config
