{
  config,
  lib,
  pkgs,
  ...
}: let
  mkBind = key: disp: {
    _args = [key (lib.generators.mkLuaInline disp)];
  };

  mkBind' = key: disp: flags: {
    _args = [key (lib.generators.mkLuaInline disp) flags];
  };

  arr = [
    1
    2
    3
    4
    5
    6
    7
    8
    9
  ];
in {
  wayland.windowManager.hyprland = lib.mkIf config.wayland.windowManager.hyprland.enable {
    settings = {
      config.binds.allow_workspace_cycles = true;

      bind =
        [
          (mkBind "CTRL + ALT + Delete" "hl.dsp.exit()")
          (mkBind "SUPER + Q" "hl.dsp.window.close()")
          (mkBind "SUPER + F" ''hl.dsp.window.float({ action = "toggle" })'')
          (mkBind "SUPER + P" "hl.dsp.window.pin()")
          (mkBind "SUPER + Z" ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
          (mkBind "SUPER + period" ''hl.dsp.layout("togglesplit")'')

          (mkBind "SUPER + up" ''hl.dsp.focus({ direction = "u" })'')
          (mkBind "SUPER + down" ''hl.dsp.focus({ direction = "d" })'')
          (mkBind "SUPER + right" ''hl.dsp.focus({ direction = "r" })'')
          (mkBind "SUPER + left" ''hl.dsp.focus({ direction = "l" })'')

          (mkBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
          (mkBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')

          # move to adjacent monitor
          (mkBind "SUPER + CTRL + left" ''hl.dsp.focus({ monitor = "l" })'')
          (mkBind "SUPER + CTRL + right" ''hl.dsp.focus({ monitor = "r" })'')

          # move window to adjacent monitor
          (mkBind "SUPER + SHIFT + CTRL + left" ''hl.dsp.window.move({ monitor = "l" })'')
          (mkBind "SUPER + SHIFT + CTRL + down" ''hl.dsp.window.move({ monitor = "d" })'')
          (mkBind "SUPER + SHIFT + CTRL + up" ''hl.dsp.window.move({ monitor = "u" })'')
          (mkBind "SUPER + SHIFT + CTRL + right" ''hl.dsp.window.move({ monitor = "r" })'')

          # move window directionally
          (mkBind "SUPER + SHIFT + left" ''hl.dsp.window.move({ direction = "l" })'')
          (mkBind "SUPER + SHIFT + down" ''hl.dsp.window.move({ direction = "d" })'')
          (mkBind "SUPER + SHIFT + up" ''hl.dsp.window.move({ direction = "u" })'')
          (mkBind "SUPER + SHIFT + right" ''hl.dsp.window.move({ direction = "r" })'')

          # focus first/last window in column
          (mkBind "SUPER + Home" ''hl.dsp.focus({ window = "first" })'')
          (mkBind "SUPER + End" ''hl.dsp.focus({ window = "last" })'')

          # workspace navigation
          (mkBind "SUPER + Page_Down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (mkBind "SUPER + Page_Up" ''hl.dsp.focus({ workspace = "e-1" })'')

          # move window to adjacent workspace
          (mkBind "SUPER + SHIFT + Page_Down" ''hl.dsp.window.move({ workspace = "e+1" })'')
          (mkBind "SUPER + SHIFT + Page_Up" ''hl.dsp.window.move({ workspace = "e-1" })'')

          # manual sizing
          (mkBind "SUPER + minus" ''hl.dsp.window.resize({ x = -100, y = 0, relative = true })'')
          (mkBind "SUPER + equal" ''hl.dsp.window.resize({ x = 100, y = 0, relative = true })'')
          (mkBind "SUPER + SHIFT + minus" ''hl.dsp.window.resize({ x = 0, y = -100, relative = true })'')
          (mkBind "SUPER + SHIFT + equal" ''hl.dsp.window.resize({ x = 0, y = 100, relative = true })'')

          # application launchers
          (mkBind "SUPER + T" ''hl.dsp.exec_cmd("ghostty")'')
          (mkBind "SUPER + space" ''hl.dsp.exec_cmd("dms ipc call spotlight toggle")'')
          (mkBind "ALT + space" ''hl.dsp.exec_cmd("dms ipc call spotlight-bar toggle")'')
          (mkBind "SUPER + V" ''hl.dsp.exec_cmd("dms ipc call clipboard toggle")'')
          (mkBind "SUPER + comma" ''hl.dsp.exec_cmd("dms ipc call settings focusOrToggle")'')
          (mkBind "SUPER + N" ''hl.dsp.exec_cmd("dms ipc call notifications toggle")'')
          (mkBind "SUPER + SHIFT + N" ''hl.dsp.exec_cmd("dms ipc call notepad toggle")'')
          (mkBind "SUPER + Y" ''hl.dsp.exec_cmd("dms ipc call dankdash wallpaper")'')
          (mkBind "SUPER + TAB" ''hl.dsp.exec_cmd("dms ipc call hypr toggleOverview")'')
          (mkBind "SUPER + X" ''hl.dsp.exec_cmd("dms ipc call powermenu toggle")'')

          # cheat sheet
          (mkBind "SUPER + SHIFT + Slash" ''hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland")'')

          # security
          (mkBind "SUPER + ALT + L" ''hl.dsp.exec_cmd("dms ipc call lock lock")'')
          (mkBind "SUPER + SHIFT + E" "hl.dsp.exit()")

          # window management
          (mkBind "SUPER + W" "hl.dsp.group.toggle()")
          (mkBind "SUPER + SHIFT + W" ''hl.dsp.exec_cmd("dms ipc call window-rules toggle")'')

          # screenshots
          (mkBind "Print" ''hl.dsp.exec_cmd("dms screenshot")'')
          (mkBind "CTRL + Print" ''hl.dsp.exec_cmd("dms screenshot full")'')
          (mkBind "ALT + Print" ''hl.dsp.exec_cmd("dms screenshot window")'')

          # display profiles & dpms
          (mkBind "SUPER + SHIFT + P" "hl.dsp.dpms({ action = \"toggle\" })")
        ]
        ++ (map (i: mkBind "SUPER + ${toString i}" "hl.dsp.focus({ workspace = ${toString i} })") arr)
        ++ (map (i: mkBind "SUPER + SHIFT + ${toString i}" "hl.dsp.window.move({ workspace = ${toString i} })") arr)
        ++ [
          # bindle (locked + repeating)
          (mkBind' "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("dms ipc call brightness increment 5 \"\"")'' {
            locked = true;
            repeating = true;
          })
          (mkBind' "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("dms ipc call brightness decrement 5 \"\"")'' {
            locked = true;
            repeating = true;
          })
          (mkBind' "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("dms ipc call audio increment 3")'' {
            locked = true;
            repeating = true;
          })
          (mkBind' "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("dms ipc call audio decrement 3")'' {
            locked = true;
            repeating = true;
          })

          # bindl (locked)
          (mkBind' "XF86AudioPlay" ''hl.dsp.exec_cmd("dms ipc call mpris playPause")'' {
            locked = true;
          })
          (mkBind' "XF86AudioPause" ''hl.dsp.exec_cmd("dms ipc call mpris playPause")'' {
            locked = true;
          })
          (mkBind' "XF86AudioPrev" ''hl.dsp.exec_cmd("dms ipc call mpris previous")'' {
            locked = true;
          })
          (mkBind' "XF86AudioNext" ''hl.dsp.exec_cmd("dms ipc call mpris next")'' {
            locked = true;
          })
          (mkBind' "CTRL + XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("dms ipc call mpris increment 3")'' {
            locked = true;
            repeating = true;
          })
          (mkBind' "CTRL + XF86AudioLowerVolume" ''hl.dsp.exec_cmd("dms ipc call mpris decrement 3")'' {
            locked = true;
            repeating = true;
          })
          (mkBind' "XF86AudioMute" ''hl.dsp.exec_cmd("dms ipc call audio mute")'' {
            locked = true;
          })
          (mkBind' "XF86AudioMicMute" ''hl.dsp.exec_cmd("dms ipc call audio micmute")'' {
            locked = true;
          })

          # bindm (mouse)
          (mkBind' "SUPER + mouse:272" "hl.dsp.window.drag()" {
            mouse = true;
          })
          (mkBind' "SUPER + mouse:273" "hl.dsp.window.resize()" {
            mouse = true;
          })
        ];

      gesture = [
        {fingers = 3; direction = "horizontal"; action = "workspace";}
      ];
    };
  };
}
