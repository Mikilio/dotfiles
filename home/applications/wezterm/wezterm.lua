local wezterm=require("wezterm")
local act=wezterm.action
local mux=wezterm.mux

local config={}
-- Use config builder object if possible
if wezterm.config_builder then config=wezterm.config_builder() end

-- Settings

config.color_scheme="Catppuccin Mocha"
config.font=wezterm.font_with_fallback { 'JetBrains Mono', 'Noto Color Emoji' }
config.window_background_opacity=0.85
config.window_close_confirmation="AlwaysPrompt"
config.scrollback_lines=3000
config.default_workspace="main"

-- Dim inactive panes
config.inactive_pane_hsb={
  saturation=0.24,
  brightness=0.5
}

-- Keys
config.leader={ key="b", mods="CTRL", timeout_milliseconds=1000 }
config.keys={
  -- Send C-b when pressing C-b twice
  { key="b", mods="LEADER|CTRL",  action=act{SendString="\x02"}},
  -- Copy Mode
  { key="[", mods="LEADER",       action=act.ActivateCopyMode },
  { key="]", mods="LEADER",       action=act.PasteFrom 'Clipboard'},
  -- Command Palette
  { key=":", mods="LEADER|SHIFT", action=act.ActivateCommandPalette },

  -- Workspaces
  { key="s", mods="LEADER",       action=act.ShowLauncherArgs { flags="FUZZY|WORKSPACES" }},
  { key="(", mods="LEADER",       action=act.SwitchWorkspaceRelative(-1) },
  { key=")", mods="LEADER",       action=act.SwitchWorkspaceRelative(1) },
  { key="l", mods="LEADER",       action=act.ActivateLastTab },
  { key="$", mods="LEADER",       action=act.PromptInputLine {
      description=wezterm.format {
        { Attribute={ Intensity="Bold" } },
        { Foreground={ AnsiColor="Fuchsia" } },
        { Text="Renaming Workspace Title...:" },
      },
      action=wezterm.action_callback(function(_, _, line)
        if line then
          mux.rename_workspace(mux.get_active_workspace(), line)
        end
      end)
    }
  },

  -- Pane keybindings
  { key="\"",mods="LEADER|SHIFT", action=act{SplitVertical={domain="CurrentPaneDomain"}}},
  { key="%", mods="LEADER|SHIFT", action=act{SplitHorizontal={domain="CurrentPaneDomain"}}},
  { key="z", mods="LEADER",       action="TogglePaneZoomState" },
  { key="h", mods="LEADER",       action=act{ActivatePaneDirection="Left"}},
  { key="j", mods="LEADER",       action=act{ActivatePaneDirection="Down"}},
  { key="k", mods="LEADER",       action=act{ActivatePaneDirection="Up"}},
  { key="l", mods="LEADER",       action=act{ActivatePaneDirection="Right"}},
  { key="H", mods="LEADER|SHIFT", action=act{AdjustPaneSize={"Left", 5}}},
  { key="J", mods="LEADER|SHIFT", action=act{AdjustPaneSize={"Down", 5}}},
  { key="K", mods="LEADER|SHIFT", action=act{AdjustPaneSize={"Up", 5}}},
  { key="L", mods="LEADER|SHIFT", action=act{AdjustPaneSize={"Right", 5}}},
  { key="d", mods="LEADER",       action=act{CloseCurrentPane={confirm=true}}},
  { key="x", mods="LEADER",       action=act{CloseCurrentPane={confirm=true}}},

  -- Tab keybindings
  { key="c", mods="LEADER",       action=act{SpawnTab="CurrentPaneDomain"}},
  { key="&", mods="LEADER|SHIFT", action=act{CloseCurrentTab={confirm=true}}},
  { key="w", mods="LEADER",       action=act.ShowTabNavigator  },
  { key="p", mods="LEADER",       action=act.ActivateTabRelative(-1) },
  { key="n", mods="LEADER",       action=act.ActivateTabRelative(1) },
  { key="l", mods="LEADER",       action=act.ActivateLastTab },
  { key=",", mods="LEADER",       action=act.PromptInputLine {
      description=wezterm.format {
        { Attribute={ Intensity="Bold" } },
        { Foreground={ AnsiColor="Fuchsia" } },
        { Text="Renaming Tab Title...:" },
      },
      action=wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end)
    }
  },
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i=1, 9 do
  table.insert(config.keys, {
    key=tostring(i),
    mods="LEADER",
    action=act.ActivateTab(i - 1)
  })
end

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar=false
config.status_update_interval=1000
config.tab_bar_at_bottom=false
wezterm.on('update-right-status', function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {}


  -- Which domain am I connected to?
  local domain = wezterm.nerdfonts.oct_globe .. "  "  .. pane:get_domain_name()
  table.insert(cells, domain)

  -- Which Workspace am I on
  local stat = wezterm.nerdfonts.fae_layers .. "  " .. window:active_workspace()
  table.insert(cells, stat)

  -- The filled in variant of the < symbol
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

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
    table.insert(elements, { Text = SOLID_LEFT_ARROW })
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
