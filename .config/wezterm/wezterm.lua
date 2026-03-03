local wezterm = require 'wezterm'

-- Returns true if we're inside a tmux session
local function in_tmux()
  local handle = io.popen('/opt/homebrew/bin/tmux info 2>/dev/null')
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
  io.popen('/opt/homebrew/bin/tmux refresh-client -S')
end

local config = wezterm.config_builder()

-- Démarre toujours dans tmux
config.default_prog = { '/bin/zsh', '-c', '/opt/homebrew/bin/tmux attach || /opt/homebrew/bin/tmux new-session' }

-- Apparence
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 14
config.line_height = 1.05
config.front_end = 'WebGpu'
config.enable_kitty_graphics = true
config.window_padding = { left = 0, right = 0, top = 28, bottom = 0 }
config.enable_tab_bar = false
config.window_background_opacity = 0.85
config.macos_window_background_blur = 7
config.window_decorations = 'RESIZE'

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
    args = { '/bin/zsh', '-c', 'open ' .. (os.getenv('HOME') or '') .. '/.config/wezterm/wezterm.lua' },
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
    local handle = io.popen('/Users/matthieuczeski/.local/share/wezterm/clipboard-paste.sh')
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
  -- Cmd+Shift+Arrows : naviguer entre panes tmux
  { key = 'LeftArrow',  mods = 'CMD|SHIFT', action = tmux('h') },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = tmux('l') },
  { key = 'UpArrow',    mods = 'CMD|SHIFT', action = tmux('k') },
  { key = 'DownArrow',  mods = 'CMD|SHIFT', action = tmux('j') },
  -- Cmd+D : split horizontal / Cmd+Shift+D : split vertical
  { key = 'd', mods = 'CMD', action = tmux('\\') },
  { key = 'd', mods = 'CMD|SHIFT', action = tmux("'") },
  -- Cmd+N : nouvelle session tmux
  { key = 'n', mods = 'CMD', action = wezterm.action_callback(function(window, pane)
    local handle = io.popen('/opt/homebrew/bin/tmux new-session -dP -F "#{session_id}"')
    local id = handle and handle:read('*l') or nil
    if handle then handle:close() end
    if id then
      io.popen('/opt/homebrew/bin/tmux switch-client -t ' .. id)
      tmux_refresh()
    end
  end)},
  -- Cmd+Up/Down : naviguer entre sessions tmux
  { key = 'UpArrow', mods = 'CMD', action = tmux('(') },
  { key = 'DownArrow', mods = 'CMD', action = tmux(')') },
  -- Cmd+Left/Right : naviguer entre windows tmux
  { key = 'LeftArrow', mods = 'CMD', action = tmux('p') },
  { key = 'RightArrow', mods = 'CMD', action = tmux('n') },
  -- Cmd+Enter : toggle fullscreen
  { key = 'Enter', mods = 'CMD', action = wezterm.action.ToggleFullScreen },
  -- Shift+Enter
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
}

return config
