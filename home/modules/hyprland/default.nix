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
    # ./keybinds.nix
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
        "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
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
        mod = {
          _var = "SUPER";
        };

        config = {
          ecosystem = {
            no_update_news = true;
          };

          general = {
            allow_tearing = true;
            layout = "master";
          };

          xwayland = {
            force_zero_scaling = true;
          };

          master = {
            mfact = 0.6;
          };

          decoration = {
            dim_inactive = false;

            shadow = {
              enabled = true;
              range = 8;
              render_power = 2;
            };

            blur = {
              enabled = true;
              size = 6;
              passes = 2;
              noise = 1.0e-2;
              contrast = 0.9;
              brightness = 0.8;
              popups = true;
            };
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

          debug = {
            disable_logs = false;
          };
        };

        curve = [
          {
            _args = [
              "easeOutQuint"
              {
                type = "bezier";
                points = [[0.23 1] [0.32 1]];
              }
            ];
          }
          {
            _args = [
              "easeInOutCubic"
              {
                type = "bezier";
                points = [[0.65 0.05] [0.36 1]];
              }
            ];
          }
          {
            _args = [
              "linear"
              {
                type = "bezier";
                points = [[0 0] [1 1]];
              }
            ];
          }
          {
            _args = [
              "almostLinear"
              {
                type = "bezier";
                points = [[0.5 0.5] [0.75 1]];
              }
            ];
          }
          {
            _args = [
              "quick"
              {
                type = "bezier";
                points = [[0.15 0] [0.1 1]];
              }
            ];
          }
          {
            _args = [
              "easy"
              {
                type = "spring";
                mass = 1;
                stiffness = 71.2633;
                dampening = 15.8273644;
              }
            ];
          }
        ];
        animation = [
          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 6;
            bezier = "default";
            style = "slidefadevert 20%";
          }
          {
            leaf = "global";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 8;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windows";
            enabled = true;
            speed = 5;
            spring = "easy";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 4;
            spring = "easy";
            style = "popin 90%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 3;
            bezier = "easeOutQuint";
            style = "popin 90%";
          }
          {
            leaf = "fadeIn";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 2;
            bezier = "easeOutQuint";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 4;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 3.5;
            spring = "easy";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 3;
            spring = "easy";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 2.5;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "fadeLayersIn";
            enabled = true;
            speed = 2.5;
            spring = "easy";
          }
          {
            leaf = "fadeLayersOut";
            enabled = true;
            speed = 2;
            bezier = "easeOutQuint";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 7;
            bezier = "easeOutQuint";
            style = "slideright";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 5;
            bezier = "easeOutQuint";
            style = "slideright";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 4;
            bezier = "easeOutQuint";
            style = "slideright";
          }
          {
            leaf = "zoomFactor";
            enabled = true;
            speed = 6;
            bezier = "easeOutQuint";
          }
        ];
      };
    };
  };
}
