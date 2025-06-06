{
  inputs,
  config,
  lib,
  pkgs,
  osConfig,
  ezConfigs,
  ...
}: let
  environment = {
    # make everything use wayland
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_IM_MODULES = "wayland;fcitx;ibus";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = 1;

    # only for XWayland but I don't remember why
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    #QT stuff
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;

    #cursor
    HYPRCURSOR_THEME = config.stylix.cursor.name;
    HYPRCURSOR_SIZE = config.stylix.cursor.name;

    #GPUs
    AQ_DRM_DEVICES = if osConfig.specialisation == {} then  "/dev/dri/card0" else "/dev/dri/card1:/dev/dri/card0";
  };
in {
  imports = [
    ./shikane.nix
    ./scratchpad.nix
    ./hyprpanel.nix
    ./hypridle.nix
  ];

  config = {
    home = {
      sessionVariables = environment;

      packages = with pkgs; [
        xorg.xprop # get properties from XWayland
        xorg.xauth # to enable ssh Xforwarding
        grim # needed by portal for screenshots
        uwsm # for UWSM
        hyprsunset # blulight filter
        wl-clipboard
      ];

      file.".XCompose".source = ./XCompose;
    };

    xdg.configFile = {
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
            path = "${ezConfigs.root}/assets/mikilio.png";
            size = 200;
            position = "0, 250";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        settings.inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0".Name = "Default";
          "Groups/0/Items/0".Name = "Keyboard";
          "Groups/0/Items/1".Name = "Mozc";
        };
      };
    };

    gtk = {
      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        extraConfig = ''gtk-im-module="fcitx"'';
      };
      gtk3.extraConfig.gtk-im-module = "fcitx";
      gtk4.extraConfig.gtk-im-module = "fcitx";
    };

    systemd.user.services.hyprpaper.Service.Slice = "background-graphical.slice";

    # enable hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      systemd.enable = false; # UWSM

      settings = {
        "$mod" = "SUPER";

        exec-once = ["uwsm app -s b -- ${lib.getExe pkgs.hyprpolkitagent}"];

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
          focus_on_activate = true;
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
            "ALT, Tab, cyclenext"
            "ALT, Tab, bringactivetotop"
            "SUPER, Tab, focuscurrentorlast"
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
            "SUPER ALT, SPACE, exec, hyprctl switchxkblayout current next"
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
          ",XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        bindm = [
          "SUPER, mouse:273, resizewindow"
          "SUPER, mouse:272, movewindow"
        ];

        windowrule = [
          #floating windows
          "float,class:^(org.gnome.Calculator)$"
          "float,class:^(org.gnome.Nautilus)$"
          "float,class:^(pavucontrol)$"
          "float,class:^(nm-connection-editor)$"
          "float,class:^(blueberry.py)$"
          "float,class:^(org.gnome.Settings)$"
          "float,class:^(org.gnome.design.Palette)$"
          "float,class:^(Color Picker)$"
          "float,class:^(xdg-desktop-portal)$"
          "float,class:^(xdg-desktop-portal-gnome)$"
          "float,class:^(transmission-gtk)$"
          "float,class:^(com.github.Aylur.ags)$"

          # smart gaps
          "bordersize 1, floating:0, onworkspace:w[tv1]"
          # "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 1, floating:0, onworkspace:f[1]"
          # "rounding 0, floating:0, onworkspace:f[1]"

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

          #Zoom meetings
          "float,class:^(zoom)$"
          "pin,title:^(zoom_linux_float_video_window)$"
          "pin,class:^(zoom)$,title:^(as_toolbar)$"

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

          #floating ephemeral terminals
          "float,class:com.mitchellh.ghostty,title:ephemeral"
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
