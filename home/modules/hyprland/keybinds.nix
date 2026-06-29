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
  wayland.windowManager.hyprland.settings = {
    config.binds.allow_workspace_cycles = true;

    bind =
      [
        (mkBind "CTRL + ALT + Delete" "hl.dsp.exit()")
        (mkBind "SUPER + Q" "hl.dsp.window.close()")
        (mkBind "SUPER + F" ''hl.dsp.window.float({ action = "toggle" })'')
        (mkBind "SUPER + P" "hl.dsp.window.pin()")
        (mkBind "SUPER + Z" "hl.dsp.window.fullscreen()")
        (mkBind "SUPER + period" ''hl.dsp.layout("togglesplit")'')

        (mkBind "SUPER + up" ''hl.dsp.focus({ direction = "u" })'')
        (mkBind "SUPER + down" ''hl.dsp.focus({ direction = "d" })'')
        (mkBind "SUPER + right" ''hl.dsp.focus({ direction = "r" })'')
        (mkBind "SUPER + left" ''hl.dsp.focus({ direction = "l" })'')

        (mkBind "SUPER + bracketleft" ''hl.dsp.focus({ workspace = "r-1" })'')
        (mkBind "SUPER + bracketright" ''hl.dsp.focus({ workspace = "r+1" })'')
        (mkBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
        (mkBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')

        (mkBind "SUPER + ALT + bracketleft" ''hl.dsp.window.move({ workspace = "r-1" })'')
        (mkBind "SUPER + ALT + bracketright" ''hl.dsp.window.move({ workspace = "r+1" })'')

        (mkBind "SUPER + CTRL + up" ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'')
        (mkBind "SUPER + CTRL + down" ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'')
        (mkBind "SUPER + CTRL + right" ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'')
        (mkBind "SUPER + CTRL + left" ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'')

        (mkBind "SUPER + ALT + up" ''hl.dsp.window.move({ x = 0, y = -20, relative = true })'')
        (mkBind "SUPER + ALT + down" ''hl.dsp.window.move({ x = 0, y = 20, relative = true })'')
        (mkBind "SUPER + ALT + right" ''hl.dsp.window.move({ x = 20, y = 0, relative = true })'')
        (mkBind "SUPER + ALT + left" ''hl.dsp.window.move({ x = -20, y = 0, relative = true })'')
      ]
      ++ (map (i: mkBind "SUPER + ${toString i}" "hl.dsp.focus({ workspace = ${toString i} })") arr)
      ++ (map (i: mkBind "SUPER + ALT + ${toString i}" "hl.dsp.window.move({ workspace = ${toString i} })") arr)
      ++ [
        # bindle (locked + repeating)
        (mkBind' "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} set 5%+")'' {
          locked = true;
          repeating = true;
        })
        (mkBind' "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("${lib.getExe pkgs.brightnessctl} set 5%-")'' {
          locked = true;
          repeating = true;
        })
        (mkBind' "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'' {
          locked = true;
          repeating = true;
        })
        (mkBind' "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'' {
          locked = true;
          repeating = true;
        })

        # bindl (locked)
        (mkBind' "XF86AudioPlay" ''hl.dsp.exec_cmd("${lib.getExe pkgs.playerctl} play-pause")'' {
          locked = true;
        })
        (mkBind' "XF86AudioStop" ''hl.dsp.exec_cmd("${lib.getExe pkgs.playerctl} pause")'' {
          locked = true;
        })
        (mkBind' "XF86AudioPause" ''hl.dsp.exec_cmd("${lib.getExe pkgs.playerctl} pause")'' {
          locked = true;
        })
        (mkBind' "XF86AudioPrev" ''hl.dsp.exec_cmd("${lib.getExe pkgs.playerctl} previous")'' {
          locked = true;
        })
        (mkBind' "XF86AudioNext" ''hl.dsp.exec_cmd("${lib.getExe pkgs.playerctl} next")'' {
          locked = true;
        })
        (mkBind' "XF86AudioMute" ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'' {
          locked = true;
        })
        (mkBind' "XF86AudioMicMute" ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'' {
          locked = true;
        })

        # bindm (mouse)
        (mkBind' "SUPER + mouse:273" "hl.dsp.window.resize()" {
          mouse = true;
        })
        (mkBind' "SUPER + mouse:272" "hl.dsp.window.drag()" {
          mouse = true;
        })
      ];
  };
}
