{
  inputs,
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  environment = {
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    # SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = 1;
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };
in {
  imports = [
  ];

  config = {
    home = {
      sessionVariables = environment;

      packages = (with pkgs; [
        xorg.xprop # get properties from XWayland
        xorg.xauth # to enable ssh Xforwarding
        wl-clipboard
      ]) ++ [
        inputs.hyprland-contrib.packages.${pkgs.stdenv.system}.grimblast
      ];

      file.".XCompose".source = ./XCompose;
    };

    xdg.configFile = {
      "Hyprland-xdg-terminals.list".text = "wezterm";
      "xkb" = {
        source = ./xkb;
        recursive = true;
      };
    };

    programs.hyprlock  = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = ''$PROMPT'';
            shadow_passes = 2;
          }
        ];
      };
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
          unlock_cmd = "pkill -USR1 hyprlock";
        };

        listener = [
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        ];
      };
    };

    # enable hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enableXdgAutostart = true;
        variables = [
          "--all"
        ];
      };


      settings = let
        pointer = config.home.pointerCursor;
      in {
        exec-once = [
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        ];

        monitor = [ ",preferred, auto, 1" ];

        xwayland = {
          force_zero_scaling = true;
        };

        general = {
          cursor_inactive_timeout = 5;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          no_gaps_when_only = 1;
        };

        decoration = {
          drop_shadow = "yes";
          shadow_range = 8;
          shadow_render_power = 2;
          "col.shadow" = "rgba(00000044)";

          dim_inactive = false;

          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            new_optimizations = "on";
            noise = 0.01;
            contrast = 0.9;
            brightness = 0.8;
            popups = true;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 5, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        input = {
          accel_profile = "flat";
          float_switch_override_focus = 2;
        };

        device = {
          name = "semico---usb-gaming-keyboard-";
          kb_layout = "us,eu";
          kb_variant = ",eurkey-cmk-dh-ansi";
          kb_options = "grp:alt_caps_toggle";
          resolve_binds_by_sym = 1;
        };

        misc = {
          disable_autoreload = true;
          vrr = 1;
        };

        binds = {
          allow_workspace_cycles = true;
        };

        bind = let
          binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
          mvfocus = binding "SUPER" "movefocus";
          ws = binding "SUPER" "workspace";
          resizeactive = binding "SUPER CTRL" "resizeactive";
          mvactive = binding "SUPER ALT" "moveactive";
          mvtows = binding "SUPER SHIFT" "movetoworkspace";
          e = "exec, asztal -b hypr";
          arr = [1 2 3 4 5 6 7 8 9];
          play = pkgs.writeShellScriptBin "play" ''
            notify-send "Opening video" "$(wl-paste)"
            mpv "$(wl-paste)"
          '';
        in
          [
            "CTRL ALT, R,   ${e} quit; asztal -b hypr"
            "SUPER, Space,  ${e} -t launcher"
            "SUPER, Escape, ${e} -t powermenu"
            "SUPER, Tab,    ${e} -t overview"

            # youtube
            ", F9,  exec, ${lib.getExe play}"
            ", F1, ${e} -r 'color.pick()'"
            ",Print,         exec, aszetal -r 'recorder.screenshot()'"
            "SHIFT,Print,    exec, aszetal -r 'recorder.screenshot(true)'"

            "ALT, Tab, focuscurrentorlast"
            "CTRL ALT, Delete, exit"
            "SUPER, Q, killactive"
            "SUPER, F, togglefloating"
            "SUPER, Z, fullscreen"
            "SUPER, M, fakefullscreen"
            "SUPER, R, layoutmsg, togglesplit"

            (mvfocus "up" "u")
            (mvfocus "down" "d")
            (mvfocus "right" "r")
            (mvfocus "left" "l")
            (ws "bracketleft" "r-1")
            (ws "bracketright" "r+1")
            ", code:195, workspace, r+1"
            ", code:194, changegroupactive, f"
            ", code:193, togglegroup"
            ", code:192, changegroupactive, b"
            ", code:191, workspace, r-1"
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
          ",XF86MonBrightnessUp,   exec, ${ lib.getExe pkgs.brightnessctl} set +5%"
          ",XF86MonBrightnessDown, exec, ${ lib.getExe pkgs.brightnessctl} set  5%-"
          ",XF86AudioRaiseVolume,  exec, ${ pkgs.pulseaudio.outPath }/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,  exec, ${ pkgs.pulseaudio.outPath }/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ];

        bindl = [
          ",XF86AudioPlay,    exec, ${ lib.getExe pkgs.playerctl} play-pause"
          ",XF86AudioStop,    exec, ${ lib.getExe pkgs.playerctl} pause"
          ",XF86AudioPause,   exec, ${ lib.getExe pkgs.playerctl} pause"
          ",XF86AudioPrev,    exec, ${ lib.getExe pkgs.playerctl} previous"
          ",XF86AudioNext,    exec, ${ lib.getExe pkgs.playerctl} next"
          ",XF86AudioMicMute, exec, ${ pkgs.pulseaudio.outPath }/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ];

        bindm = [
          "SUPER, mouse:273, resizewindow"
          "SUPER, mouse:272, movewindow"
        ];

        windowrule = let
          f = regex: "float, ^(${regex})$";
        in [
          (f "org.gnome.Calculator")
          (f "org.gnome.Nautilus")
          (f "pavucontrol")
          (f "nm-connection-editor")
          (f "blueberry.py")
          (f "org.gnome.Settings")
          (f "org.gnome.design.Palette")
          (f "Color Picker")
          (f "xdg-desktop-portal")
          (f "xdg-desktop-portal-gnome")
          (f "transmission-gtk")
          (f "com.github.Aylur.ags")
        ];

        windowrulev2 = [
          #weird wezterm workaround
          "float,class:^(org.wezfurlong.wezterm)$"
          "tile,class:^(org.wezfurlong.wezterm)$"
          #optimization
          "noshadow, floating:0"
          #xwaylandvideobridge
          "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "nofocus,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
          # fix xwayland apps
          "rounding 0, xwayland:1, floating:1"
          #don't touch: "fullscreen, forceinput, xwayland:1, class:^(league of legends.exe)$"
          #main apps
          "workspace 1 silent, class:^(Alacritty|org.wezfurlong.wezterm)$"
          "workspace 2 silent, class:^(vivaldi-stable|firefox)$"
          # make picture in picture a nice pinned window
          "keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "noborder,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "fakefullscreen,class:^(firefox)$,title:^(Firefox)$"
          "fakefullscreen,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "pin,class:^(firefox)$,title:^(Firefox)$"
          "pin,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "float,class:^(firefox)$,title:^(Firefox)$"
          "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
        ];
      };
    };
  };
}
