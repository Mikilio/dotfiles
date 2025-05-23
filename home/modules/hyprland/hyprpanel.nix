{
  inputs,
  lib,
  pkgs,
  ezConfigs,
  config,
  ...
}:
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  programs.hyprpanel = {

    enable = true;
    overwrite.enable = true;

    # Configure and theme almost all options from the GUI.
    # Options that require '{}' or '[]' are not yet implemented,
    # except for the layout above.
    # See 'https://hyprpanel.com/configuration/settings.html'.
    # Default: <same as gui>
    settings = {
      # Configure bar layouts for monitors.
      # See 'https://hyprpanel.com/configuration/panel.html'.
      # Default: null
      layout = {
        "bar.layouts" = {
          "*" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
              "systray"
              # "kbinput"
            ];
            middle = [
              "media"
            ];
            right = [
              "volume"
              "network"
              "bluetooth"
              "hyprsunset"
              "battery"
              "clock"
              "notifications"
            ];
          };
        };
      };

      bar = {
        launcher.autoDetectIcon = true;
        workspaces.ignored = "-\\d+";
        # systray.ignore = ["nm-applet"];
        clock.format = "%a %b %d  %I:%M %p";
        customModules.hyprsunset.temperature = "12000k";
      };

      menus = {
        clock = {
          time = {
            military = true;
          };
          weather = {
            unit = "metric";
            location = "Munich";
            key = config.sops.secrets.weather.path;
          };
        };

        dashboard = {
          directories = {
            left = {
              directory1.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $XDG_DOWNLOAD_DIR";
              directory1.label = "󰉍 Downloads";
              directory2.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $XDG_VIDEOS_DIR";
              directory2.label = "󰉏 Videos";
              directory3.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $XDG_DEV_DIR";
              directory3.label = "󰚝 Code";
            };
            right = {
              directory1.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $XDG_DOCUMENTS_DIR";
              directory1.label = "󱧶 Documents";
              directory2.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $XDG_PICTURES_DIR";
              directory2.label = "󰉏 Pictures";
              directory3.command = "${lib.getExe pkgs.ghostty} --title=ephemeral -e yazi $HOME";
              directory3.label = "󱂵 Home";
            };
          };

          powermenu = {
            avatar.image = "${ezConfigs.root}/assets/mikilio.png";
            logout = "loginctl terminate-user ${config.home.username}";
          };

          shortcuts.left = {
            shortcut1 = {
              command = "floorp";
              icon = "";
              tooltip = "Browser";
            };
            shortcut2 = {
              command = "thunderbird";
              icon = "󰇮";
              tooltip = "E-Mail";
            };
            shortcut3 = {
              command = "steam";
              icon = "󰓓";
              tooltip = "Games";
            };
            shortcut4 = {
              command = "anyrun";
              icon = "";
              tooltip = "Search Apps";
            };
          };
        };

        power.lowBatteryNotification = true;
      };

      scalingPriority = "hyprland";
      tear = true;

      terminal = "${pkgs.foot}/bin/footclient";

      theme = {
        name = "catppuccin_mocha";
        bar = {
          buttons.enableBorders = true;
          transparent = true;
          outer_spacing = "0";
          buttons.style = "wave";
        };
        font = {
          size = "0.8rem";
          inherit (config.stylix.fonts.sansSerif) name;
        };
      };

      wallpaper.enable = false;
    };
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [ "uwsm app -s b -- ${pkgs.networkmanagerapplet}/bin/nm-applet" ];
    bind = [
      "CTRL ALT, R, exec, systemctl --user restart hyprpanel.service"
    ];
  };

  systemd.user.services.hyprpanel = {
    Unit = {

      Description = "A Bar/Panel for Hyprland";
      # order startup after WM
      # After = ["wayland-session@hyprland.desktop.target"];
      After = ["graphical-session.target"];
    };

    Service = {

      Type = "exec";
      # Repurpose XDG Autostart filtering
      ExecStart = "${pkgs.hyprpanel}/bin/hyprpanel";
      ExecReload = "${pkgs.hyprpanel}/bin/hyprpanel restart";
      Restart = "always";
      RestartSec = 1;
      TimeoutStopSec = 10;
      Slice = "app-graphical.slice";
    };

    Install = {

      # WantedBy = ["wayland-session@hyprland.desktop.target"];
      WantedBy = ["graphical-session.target"];
    };
  };
}
