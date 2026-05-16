{
  config,
  lib,
  pkgs,
  ...
}: let
  binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
  mvfocus = binding "SUPER" "movefocus";
  ws = binding "SUPER" "workspace";
  resizeactive = binding "SUPER CTRL" "resizeactive";
  mvactive = binding "SUPER ALT" "moveactive";
  mvtows = binding "SUPER ALT" "movetoworkspace";
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
    binds = {
      allow_workspace_cycles = true;
    };

    bind =
      [
        "CTRL ALT, Delete, exit"
        "SUPER, Q, killactive"
        "SUPER, F, togglefloating"
        "SUPER, P, pin"
        "SUPER, Z, fullscreen"
        "SUPER, ., layoutmsg, togglesplit"

        (mvfocus "up" "u")
        (mvfocus "down" "d")
        (mvfocus "right" "r")
        (mvfocus "left" "l")
        (ws "bracketleft" "r-1")
        (ws "bracketright" "r+1")
        (ws "mouse_up" "e-1")
        (ws "mouse_down" "e+1")
        (mvtows "bracketleft" "r-1")
        (mvtows "bracketright" "r+1")
        (resizeactive "up" "0 -20")
        (resizeactive "down" "0 20")
        (resizeactive "right" "20 0")
        (resizeactive "left" "-20 0")
        (mvactive "up" "0 -20")
        (mvactive "down" "0 20")
        (mvactive "right" "20 0")
        (mvactive "left" "-20 0")
      ]
      ++ (map (i: ws (toString i) (toString i)) arr)
      ++ (map (i: mvtows (toString i) (toString i)) arr);

    bindle = [
      ",XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} set 5%+"
      ",XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%-"
      ",XF86AudioRaiseVolume,  exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume,  exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    bindl = [
      ",XF86AudioPlay,    exec, ${lib.getExe pkgs.playerctl} play-pause"
      ",XF86AudioStop,    exec, ${lib.getExe pkgs.playerctl} pause"
      ",XF86AudioPause,   exec, ${lib.getExe pkgs.playerctl} pause"
      ",XF86AudioPrev,    exec, ${lib.getExe pkgs.playerctl} previous"
      ",XF86AudioNext,    exec, ${lib.getExe pkgs.playerctl} next"
      ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindm = [
      "SUPER, mouse:273, resizewindow"
      "SUPER, mouse:272, movewindow"
    ];
  };
}
