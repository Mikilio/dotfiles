{
  config,
  lib,
  pkgs,
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
    #for EurKey
    XCOMPOSEFILE = "$HOME/.XCompose";

    #QT stuff
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
  };
in {
  imports = [
    ./keybinds.nix
    ./scratchpad.nix
  ];
  options.i18n.inputMethod.fcitx5.imList = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = ''
      List of input method names to configure in the default fcitx5 group.
    '';
    example = ["keyboard-us" "keyboard-ua" "mozc"];
  };
  config = {
    home = {
      sessionVariables = environment;

      packages = with pkgs; [
        xprop # get properties from XWayland
        xauth # to enable ssh Xforwarding
        grim # needed by portal for screenshots
        uwsm # for UWSM
        hyprsunset # blulight filter
        wl-clipboard
      ];

      file.".XCompose".source = ./XCompose;
    };

    services.polkit-gnome.enable = true;

    xdg = {
      portal = {
        xdgOpenUsePortal = true;
        config.hyprland.default = "hyprland;gtk";
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      configFile = {
        "xkb" = {
          source = ./xkb;
          recursive = true;
        };
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = let
        imList = config.i18n.inputMethod.fcitx5.imList;
        hasMozc = builtins.elem "mozc" imList;
      in {
        waylandFrontend = true;
        addons = with pkgs; [fcitx5-gtk] ++ lib.optional hasMozc fcitx5-mozc;
        settings = {
          globalOptions = {
            Behavior = {
              ShareInputState = "All";
            };
            "Hotkey/TriggerKeys"."0" = "Alt+Shift+Shift_L";
          };
          inputMethod = let
            defaultLang = builtins.elemAt (lib.strings.splitString "-" (builtins.head imList)) 1;
          in
            {
              GroupOrder."0" = "Default";
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = defaultLang;
                DefaultIM =
                  builtins.elemAt imList 1;
              };
            }
            // (lib.listToAttrs (lib.lists.imap0 (idx: name: {
                name = "Groups/0/Items/${toString idx}";
                value = {Name = name;};
              })
              imList));
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
      systemd.enable = false; # UWSM

      settings = {
        "$mod" = "SUPER";

        ecosystem = {
          no_update_news = true;
        };

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
          kb_layout = "eu";
          kb_variant = "basic";
        };

        misc = {
          disable_autoreload = true;
          vrr = 1;
          focus_on_activate = true;
        };

        windowrule = [
          #floating windows
          "float 1,match:class ^(org.gnome.Calculator)$"
          "float 1,match:class ^(org.gnome.Nautilus)$"
          "float 1,match:class ^(pavucontrol)$"
          "float 1,match:class ^(nm-connection-editor)$"
          "float 1,match:class ^(blueberry.py)$"
          "float 1,match:class ^(org.gnome.Settings)$"
          "float 1,match:class ^(org.gnome.design.Palette)$"
          "float 1,match:class ^(Color Picker)$"
          "float 1,match:class ^(xdg-desktop-portal)$"
          "float 1,match:class ^(xdg-desktop-portal-gnome)$"
          "float 1,match:class ^(transmission-gtk)$"
          "float 1,match:class ^(com.github.Aylur.ags)$"

          # smart gaps
          "border_size 1, match:float 0, match:workspace w[tv1]"
          # "rounding 0, match:float 0, match:workspace w[tv1]"
          "border_size 1, match:float 0, match:workspace f[1]"
          # "rounding 0, match:float 0, match:workspace f[1]"

          #markdown preview for neovim
          "tile 1, match:title ^(Markdown Preview)(.*)$"

          #optimization
          "no_shadow 1, match:float 0"

          # fix xwayland apps
          "rounding 0, match:xwayland 1, match:float 1"

          #Zoom meetings
          "float 1,match:class ^(zoom)$"
          "pin 1,match:title ^(zoom_linux_float_video_window)$"
          "pin 1,match:class ^(zoom)$,match:title ^(as_toolbar)$"

          #allow tearing for steam games
          "immediate 1, match:class ^(steam_app_)(.*)$"

          # make picture in picture a nice pinned window
          "float 1, pin 1, keep_aspect_ratio 1, border_size 0, match:class ^(firefox)$,match:title ^(Picture-in-Picture)$"
          "float 1, pin 1, keep_aspect_ratio 1,border_size 0, match:initial_title ^(Discord Popout)$"

          #workarount for thunderai
          "float 1,match:class thunderbird,match:title ^(?!Mozilla*)"

          #floating ephemeral terminals
          "float 1,match:class com.mitchellh.ghostty,match:title ephemeral"
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
