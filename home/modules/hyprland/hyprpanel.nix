{
  pkgs,
  config,
  ...
}: {
  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;

    # Configure and theme almost all options from the GUI.
    # Options that require '{}' or '[]' are not yet implemented,
    # except for the layout above.
    # See 'https://hyprpanel.com/configuration/settings.html'.
    # Default: <same as gui>
    settings = {
      hyprpanel.restartCommand = "systemctl --user restart hyprpanel.service";
      bar = {
        launcher.autoDetectIcon = true;
        workspaces.ignored = "-\\d+";
        # systray.ignore = ["nm-applet"];
        clock.format = "%a %b %d  %I:%M %p";
        customModules.hyprsunset.temperature = "12000k";
        layouts = {
          "*" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
              "systray"
              # "kbinput"
            ];
            middle = [
              "notifications"
              "media"
            ];
            right = [
              "volume"
              "network"
              "bluetooth"
              "hyprsunset"
              "hypridle"
              "battery"
              "clock"
            ];
          };
        };
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
          directories = with pkgs; {
            left = {
              directory1.command = "bash -c \"${xdg-utils}/bin/xdg-open $XDG_DOWNLOAD_DIR\"";
              directory1.label = "󰉍 Downloads";
              directory2.command = "bash -c \"${xdg-utils}/bin/xdg-open $XDG_VIDEOS_DIR\"";
              directory2.label = "󰉏 Videos";
              directory3.command = "bash -c \"${xdg-utils}/bin/xdg-open $XDG_DEV_DIR\"";
              directory3.label = "󰚝 Code";
            };
            right = {
              directory1.command = "bash -c \"${xdg-utils}/bin/xdg-open $XDG_DOCUMENTS_DIR\"";
              directory1.label = "󱧶 Documents";
              directory2.command = "bash -c \"${xdg-utils}/bin/xdg-open $XDG_PICTURES_DIR\"";
              directory2.label = "󰉏 Pictures";
              directory3.command = "bash -c \"${xdg-utils}/bin/xdg-open $HOME\"";
              directory3.label = "󱂵 Home";
            };
          };

          powermenu = {
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

  services.network-manager-applet.enable = true;
  wayland.windowManager.hyprland.settings = {
    bind = [
      "CTRL ALT, R, exec, systemctl --user restart hyprpanel.service"
    ];
  };
}
