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
config.default_prog = { '/bin/zsh', '-c', tmux_bin .. ' attach || ' .. tmux_bin .. ' new-session' }

-- Apparence
-- config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 14
config.line_height = 1.05
config.front_end = 'WebGpu'
config.enable_kitty_graphics = true
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_tab_bar = false
config.window_background_opacity = 0.78
config.macos_window_background_blur = 0
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

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
  { key = 'LeftArrow',  mods = 'CMD|ALT|SHIFT', action = wezterm.action_callback(function() io.popen(tmux_bin .. ' swap-pane -s "{left-of}"') end) },
  { key = 'RightArrow', mods = 'CMD|ALT|SHIFT', action = wezterm.action_callback(function() io.popen(tmux_bin .. ' swap-pane -s "{right-of}"') end) },
  { key = 'UpArrow',    mods = 'CMD|ALT|SHIFT', action = wezterm.action_callback(function() io.popen(tmux_bin .. ' swap-pane -s "{up-of}"') end) },
  { key = 'DownArrow',  mods = 'CMD|ALT|SHIFT', action = wezterm.action_callback(function() io.popen(tmux_bin .. ' swap-pane -s "{down-of}"') end) },
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
  { key = 'n', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    local handle = io.popen(tmux_bin .. ' new-session -dP -F "#{session_id}"')
    local id = handle and handle:read('*l') or nil
    if handle then handle:close() end
    if id then
      io.popen(tmux_bin .. ' switch-client -t ' .. id)
      tmux_refresh()
    end
  end)},
  -- Cmd+Up/Down : naviguer entre sessions tmux
  { key = 'UpArrow', mods = 'CMD', action = tmux('(') },
  { key = 'DownArrow', mods = 'CMD', action = tmux(')') },
  -- Cmd+Left/Right : naviguer entre windows tmux
  { key = 'LeftArrow', mods = 'CMD', action = tmux('p') },
  { key = 'RightArrow', mods = 'CMD', action = tmux('n') },
  -- Cmd+< / Cmd+> : cycle thèmes
  { key = '<', mods = 'CMD', action = wezterm.action_callback(function(window) cycle_theme(window, -1) end) },
  { key = '>', mods = 'CMD', action = wezterm.action_callback(function(window) cycle_theme(window, 1) end) },
  -- Cmd+Q : ferme WezTerm sans toucher aux sessions tmux
  { key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication },
  -- Cmd++ / Cmd+- / Cmd+0 : zoom
  { key = '+', mods = 'CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize },
  -- Cmd+F : toggle fullscreen
  { key = 'f', mods = 'CMD', action = wezterm.action.ToggleFullScreen },
  -- Shift+Enter
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
  -- Cmd+E : toggle yazi sidebar
  { key = 'e', mods = 'CMD', action = wezterm.action_callback(function()
    io.popen(find_bin('tmux', '/opt/homebrew/bin/tmux') .. ' run-shell -b "~/.local/bin/yazi-toggle.sh"')
  end)},
}

return config
