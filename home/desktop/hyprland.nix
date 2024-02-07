{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib; let
  environment = {
    GDK_BACKEND="wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
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

  config = {
    home =  {
      sessionVariables = environment;

      packages = with pkgs; [
        xorg.xprop # get properties from XWayland
        xorg.xauth # to enable ssh Xforwarding
        hyprpaper
        inputs'.hyprland-contrib.packages.grimblast
      ];
    };

    xdg.configFile = let
      wallpapers = "${config.xdg.userDirs.pictures}/wallpapers";
      portrait = "${wallpapers}/portrait";
      landscape = "${wallpapers}/landscape";
    in {
      "Hyprland-xdg-terminals.list".text = "";
      "hypr/hyprpaper.conf".text = ''
        preload = ${portrait}/default.jpg
        preload = ${landscape}/default.jpg

        wallpaper = DP-1, ${landscape}/default.jpg

        wallpaper = DP-2, ${portrait}/default.jpg
      '';
    };

    # enable hyprland
    wayland.windowManager.hyprland = {
      enable = true;

      settings = let
        pointer = config.home.pointerCursor;
        home = config.home.homeDirectory;
        terminal = config.home.sessionVariables.TERM;
        launcher = "anyrun";
      in {
        exec-once = [
          "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        ];

        monitor = [
          "DP-1, 2560x1440, 0x0, 1"
          "DP-2, 1920x1080, -1080x0, 1, transform, 1"
        ];

        xwayland = {
          force_zero_scaling = true;
        };

        general = {
          cursor_inactive_timeout	= 5;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          no_gaps_when_only = 1;
        };

        decoration = {
          shadow_range = 8;
          shadow_render_power = 2;
          "col.shadow" = "rgba(00000044)";

          inactive_opacity = 0.8;
          dim_inactive = true;

          blur = {
            enabled = true;
            size = 8;
            passes = 3;
            noise = 0.01;
            contrast = 0.9;
            brightness = 0.8;
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
          e = "exec, ags -b hypr";
          arr = [1 2 3 4 5 6 7 8 9 0];
          play = pkgs.writeShellScriptBin "play" ''
              notify-send "Opening video" "$(wl-paste)"
              mpv "$(wl-paste)"
          '';
        in [
          "CTRL ALT, R,   ${e} quit; ags -b hypr"
          "SUPER, Space,  ${e} -t applauncher"
          "SUPER, Escape, ${e} -t powermenu"
          "SUPER, Tab,    ${e} -t overview"

          # youtube
          ", F9,  exec, ${getExe play}"
          ", F1, ${e} -r 'color.pick()'"

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
          (ws "bracketleft" "e-1")
          (ws "bracketright" "e+1")
          ", code:195, workspace, e+1"
          ", code:194, workspace, name:Web"
          ", code:193, workspace, name:Terminal"
          ", code:192, workspace, name:Sidepanel"
          ", code:191, workspace, e-1"
          (mvtows "bracketleft" "e-1")
          (mvtows "bracketright" "e+1")
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

        bindle = let e = "exec, ags -b hypr -r"; in [
          #TODO: uncomment after fixing ags
          # ",XF86MonBrightnessUp,   ${e} 'brightness.screen += 0.05; indicator.display()'"
          # ",XF86MonBrightnessDown, ${e} 'brightness.screen -= 0.05; indicator.display()'"
          ",XF86AudioRaiseVolume,  ${e} 'audio.speaker.volume += 0.05; indicator.speaker()'"
          ",XF86AudioLowerVolume,  ${e} 'audio.speaker.volume -= 0.05; indicator.speaker()'"
        ];

        bindl = let e = "exec, ags -b hypr -r"; in [
          ",XF86AudioPlay,    ${e} 'mpris?.playPause()'"
          ",XF86AudioStop,    ${e} 'mpris?.stop()'"
          ",XF86AudioPause,   ${e} 'mpris?.pause()'"
          ",XF86AudioPrev,    ${e} 'mpris?.previous()'"
          ",XF86AudioNext,    ${e} 'mpris?.next()'"
          ",XF86AudioMicMute, ${e} 'audio.microphone.isMuted = !audio.microphone.isMuted'"
        ];

        bindm = [
          "SUPER, mouse:273, resizewindow"
          "SUPER, mouse:272, movewindow"
        ];

        windowrulev2 = [
          #optimization
          "noshadow, floating:0"
          #Keepassxc
          "float, class:^(org.keepassxc.KeePassXC)$"
          "pin, class:^(org.keepassxc.KeePassXC)$"
          #xwaylandvideobridge
          "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
          "noanim,class:^(xwaylandvideobridge)$"
          "nofocus,class:^(xwaylandvideobridge)$"
          "noinitialfocus,class:^(xwaylandvideobridge)$"
          #OBS preview
          "workspace name:󰹑  silent, title:^(Windowed Projector \\(Preview\\))$"
          "monitor DP-1, title:^(Windowed Projector \\(Preview\\))$"
          "float, title:^(Windowed Projector \\(Preview\\))$"
          "size 1920 1080, title:^(Windowed Projector \\(Preview\\))$"
          # fix xwayland apps
          "rounding 0, xwayland:1, floating:1"
          #don't touch: "fullscreen, forceinput, xwayland:1, class:^(league of legends.exe)$"
          #main apps
          "workspace name:Terminal silent, class:^(Alacritty|org.wezfurlong.wezterm)$"
          "workspace name:Web silent, class:^(vivaldi-stable|firefox)$"
          #Tray apps in Sidepane
          "tile, title:^(Spotify)$"
          "workspace name:Sidepanel silent, title:^(Spotify)$"
          "workspace name:Sidepanel silent, class:^org.telegram.desktop$"
          "workspace name:Sidepanel silent, title:^(.*(Discord|Vesktop).*)$"
        ];

        workspace = [
          "name:Terminal, rounding:false, decorate:false, border:false, monitor:DP-1, default:true"
          "name:Sidepanel, monitor:DP-2, default:true"
          "name:Web, rounding:false, decorate:false, monitor:DP-1"
        ];

      };
    };

    systemd.user = {

      sessionVariables = environment // {
        PATH = "${config.home.homeDirectory}/.nix-profile/bin" +
          ":${getBin pkgs.coreutils}/bin";
      };

      targets = {
        hyprland-session = {
          Unit = {
            Wants = [ "xdg-desktop-autostart.target" ];
          };
        };
      };
      services = {
        xdg-desktop-portal-hyprland = {
          Unit = {
            Description = "Portal service (Hyprland implementation)";
            ConditionEnvironment = "WAYLAND_DISPLAY";
            PartOf = "graphical-session.target";
          };
          Service = {
            Type = "dbus";
            BusName = "org.freedesktop.impl.portal.desktop.hyprland";
            ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
            Restart = "on-failure";
            Slice = "session.slice";
          };
        };
      };
    };
  };
})
