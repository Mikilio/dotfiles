{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  environment = {
    # make everything use wayland
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = 1;

    # only for XWayland but I don't remember why
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_QPA_PLATFORMTHEME = "qt5ct";

    HYPRCURSOR_THEME = config.stylix.cursor.name;
    HYPRCURSOR_SIZE = config.stylix.cursor.name;
  };
in
{
  imports = [
    ./shikane.nix
    ./scratchpad.nix
  ];

  config = {
    home = {
      sessionVariables = environment;

      packages =
        (with pkgs; [
          xorg.xprop # get properties from XWayland
          xorg.xauth # to enable ssh Xforwarding
          hyprpolkitagent # UI for polkit
          wl-clipboard
        ])
        ++ [
          inputs.hyprland-contrib.packages.${pkgs.stdenv.system}.grimblast
        ];

      file.".XCompose".source = ./XCompose;
    };

    xdg.configFile = {
      "Hyprland-xdg-terminals.list".text = "foot";
      "xkb" = {
        source = ./xkb;
        recursive = true;
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {

        # GENERAL
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };

        label = [
          # TIME
          {
            text = ''cmd[update:30000] echo "$(date +"%R")"'';
            font_size = 90;
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          # DATE
          {
            text = ''cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"'';
            font_size = 25;
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
        ];

        image = [
          # USER AVATAR
          {
            path = "~/.face";
            size = 200;
            position = "0, 250";
            halign = "center";
            valign = "center";
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
      package = pkgs.hyprland;
      systemd = {
        enableXdgAutostart = true;
        variables = [
          "--all"
        ];
      };

      settings = {
        "$mod" = "SUPER";

        monitor = [
          "desc:Chimei Innolux Corporation 0x1435,preferred,auto-down,1.2"
          ",preferred,auto-up,auto"
        ];

        general = {
          border_size = 2;
          allow_tearing = true;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        decoration = {

          dim_inactive = false;
          rounding = 8;

          shadow = {
            enabled = true;
            range = 8;
            render_power = 2;
          };

          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            new_optimizations = "on";
            noise = 1.0e-2;
            contrast = 0.9;
            brightness = 0.8;
            popups = true;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 3, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
            "specialWorkspace, 1, 6, default, slidefadevert 20%"
          ];
        };

        input = {
          accel_profile = "flat";
          float_switch_override_focus = 2;
        };

        device = [
          {
            name = "at-translated-set-2-keyboard";
            kb_layout = "eu,us";
            kb_variant = "eurkey-cmk-dh-iso,";
            resolve_binds_by_sym = 1;
          }
          {
            name = "semico---usb-gaming-keyboard-";
            kb_layout = "eu,us";
            kb_variant = "eurkey-cmk-dh-ansi,";
            resolve_binds_by_sym = 1;
          }
        ];

        misc = {
          disable_autoreload = true;
          vrr = 1;
        };

        binds = {
          allow_workspace_cycles = true;
        };

        bind =
          let
            binding =
              mod: cmd: key: arg:
              "${mod}, ${key}, ${cmd}, ${arg}";
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
          in
          [
            "ALT, Tab, focuscurrentorlast"
            "CTRL ALT, Delete, exit"
            "SUPER, Q, killactive"
            "SUPER, F, togglefloating"
            "SUPER, P, pin"
            "SUPER, Z, fullscreen"
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
          ",XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} set +5%"
          ",XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set  5%-"
          ",XF86AudioRaiseVolume,  exec, ${pkgs.pulseaudio.outPath}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,  exec, ${pkgs.pulseaudio.outPath}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ];

        bindl = [
          "ALT, code:66,      exec, hyprctl switchxkblayout current next"
          ",XF86AudioPlay,    exec, ${lib.getExe pkgs.playerctl} play-pause"
          ",XF86AudioStop,    exec, ${lib.getExe pkgs.playerctl} pause"
          ",XF86AudioPause,   exec, ${lib.getExe pkgs.playerctl} pause"
          ",XF86AudioPrev,    exec, ${lib.getExe pkgs.playerctl} previous"
          ",XF86AudioNext,    exec, ${lib.getExe pkgs.playerctl} next"
          ",XF86AudioMicMute, exec, ${pkgs.pulseaudio.outPath}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ];

        bindm = [
          "SUPER, mouse:273, resizewindow"
          "SUPER, mouse:272, movewindow"
        ];

        windowrule =
          let
            f = regex: "float, ^(${regex})$";
          in
          [
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
          # smart gaps
          "bordersize 0, floating:0, onworkspace:w[tv1]"
          "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"

          #markdown preview for neovim
          "tile,title:^(Markdown Preview)(.*)$"

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

          #allow tearing for steam games
          "immediate, class:^(steam_app_)(.*)$"

          # make picture in picture a nice pinned window
          "keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "keepaspectratio,initialTitle:^(Discord Popout)$"
          "noborder,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "noborder,initialTitle:^(Discord Popout)$"
          "pin,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "pin,initialTitle:^(Discord Popout)$"
          "float,class:^(firefox)$,title:^(Picture-in-Picture)$"
          "float,initialTitle:^(Discord Popout)$"

          #workarount for thunderai
          "float,class:thunderbird,title:^(?!Mozilla*)"
        ];

        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ];

        debug.disable_logs = false;
      };
    };
  };
}
