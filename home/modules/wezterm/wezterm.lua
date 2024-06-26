local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local function is_vim(pane)
  local process_name = string.gsub(pane:get_foreground_process_name(), '(.*[/\\])(.*)', '%2')
  return process_name == 'nvim' or process_name == 'vim'
end

local direction_keys = {
  LeftArrow  = 'Left',
  DownArrow  = 'Down',
  UpArrow    = 'Up',
  RightArrow = 'Right',
  j          = 'Left',
  k          = 'Down',
  l          = 'Up',
  h          = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'ALT' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'ALT' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then config = wezterm.config_builder() end

-- Settings

config.color_scheme = "Catppuccin Mocha"
-- config.window_background_opacity = 0.85
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.3,
  brightness = 0.2
}

-- startup
wezterm.on('gui-startup', function(cmd)
  -- allow `wezterm start -- something` to affect what we spawn
  -- in our initial window
  local args = {}
  if cmd then
    args = cmd.args
  end

  if args ~= nil then
    mux.spawn_window { args = args, }
  else
    -- Set a workspace for coding
    -- Top pane is for the editor, bottom pane is for the build tool
    local start_dir = wezterm.home_dir
    local edit_tab, build_pane, dev_window = mux.spawn_window {
      workspace = 'dev',
      cwd = start_dir,
    }
    build_pane:split {
      direction = 'Top',
      size = 0.8,
      cwd = start_dir,
      args = { 'nvim' },
      set_environment_variables = {
        NVIM_BUILD_PANE_ID = tostring(build_pane:pane_id()),
      },
    }

    local yazi, _, _ = dev_window:spawn_tab {
      args = { 'yazi' }
    }
    yazi:set_title 'yazi'
    local _, _, _ = dev_window:spawn_tab {
      args = { 'nu' }
    }

    -- We want to startup in the coding workspace
    mux.set_active_workspace 'dev'
    edit_tab:activate()
  end
end)


-- Keys
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {

  -- Workspaces
  { key = "s", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
  { key = "(", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = ")", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "l", mods = "LEADER",       action = act.ActivateLastTab },
  { key = 'd', mods = 'LEADER',       action = act.DetachDomain 'CurrentPaneDomain', },
  {
    key = "$",
    mods = "LEADER|SHIFT",
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Renaming Workspace Title...:" },
      },
      action = wezterm.action_callback(function(_, _, line)
        if line then
          mux.rename_workspace(mux.get_active_workspace(), line)
        end
      end)
    }
  },

  -- Tab keybindings
  { key = "c", mods = "LEADER",       action = act { SpawnTab = "CurrentPaneDomain" } },
  { key = "&", mods = "LEADER|SHIFT", action = act { CloseCurrentTab = { confirm = true } } },
  { key = "w", mods = "LEADER",       action = act.ShowTabNavigator },
  { key = "p", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
  { key = "n", mods = "LEADER",       action = act.ActivateTabRelative(1) },
  { key = "l", mods = "LEADER",       action = act.ActivateLastTab },
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Renaming Tab Title...:" },
      },
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end)
    }
  },

  -- Pane keybindings
  { key = "\"", mods = "LEADER|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "=",  mods = "LEADER",       action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "%",  mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "\\", mods = "LEADER",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "z",  mods = "LEADER",       action = act.TogglePaneZoomState },
  { key = "q",  mods = "LEADER",       action = act.PaneSelect },
  -- move between split panes
  split_nav('move', 'LeftArrow'),
  split_nav('move', 'DownArrow'),
  split_nav('move', 'UpArrow'),
  split_nav('move', 'RightArrow'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  split_nav('move', 'h'),
  -- resize panes
  split_nav('resize', 'LeftArrow'),
  split_nav('resize', 'DownArrow'),
  split_nav('resize', 'UpArrow'),
  split_nav('resize', 'RightArrow'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  split_nav('move', 'h'),
  { key = "x",     mods = "LEADER",                   action = act.CloseCurrentPane { confirm = true } },
  { key = "Space", mods = "LEADER",                   action = act.RotatePanes 'Clockwise' },

  -- Copy Mode
  { key = "[",     mods = "LEADER",                   action = act.ActivateCopyMode },
  { key = "]",     mods = "LEADER",                   action = act.PasteFrom 'Clipboard' },

  -- Command Palette
  { key = ":",     mods = "LEADER|SHIFT",             action = act.ActivateCommandPalette },

  -- Clipboard passthrough
  { key = 'Paste', action = act.PasteFrom 'Clipboard' },
  {
    key = 'Copy',
    action = wezterm.action_callback(function(window, pane, _)
      local sel = window:get_selection_text_for_pane(pane)
      if (not sel or sel == '') then
        window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'SHIFT|CTRL' }, pane)
      else
        window:perform_action(wezterm.action { CopyTo = 'Clipboard' }, pane)
      end
    end)
  },
  {
    key = 'raw:145',
    action = wezterm.action_callback(function(window, pane, _)
      local sel = window:get_selection_text_for_pane(pane)
      if (not sel or sel == '') then
        window:perform_action(wezterm.action.SendKey { key = 'x', mods = 'SHIFT|CTRL' }, pane)
      else
        window:perform_action(wezterm.action { CopyTo = 'Clipboard' }, pane)
      end
    end)
  },

  -- Fonts
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1)
  })
end

-- remove defaults
config.disable_default_key_bindings = true

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
wezterm.on('update-right-status', function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {}


  -- Which domain am I connected to?
  local domain = wezterm.nerdfonts.oct_globe .. "  " .. pane:get_domain_name()
  table.insert(cells, domain)

  -- Which Workspace am I on
  local stat = wezterm.nerdfonts.fae_layers .. "  " .. window:active_workspace()
  table.insert(cells, stat)

  -- Color palette for the backgrounds of each cell
  local colors = {
    '#3c1361',
    '#52307c',
    '#663a82',
    '#7c5295',
    '#b491c8',
  }

  -- Foreground color for the text across the fade
  local text_fg = '#c0c0c0'

  -- The elements to be formatted
  local elements = {}
  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  local function push(text)
    local cell_no = num_cells + 1
    table.insert(elements, { Foreground = { Color = colors[cell_no] } })
    table.insert(elements, { Text = '' })
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Background = { Color = colors[cell_no] } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell)
  end

  window:set_right_status(wezterm.format(elements))
end)

return config
