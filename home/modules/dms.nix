{
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  config =
    {
      systemd.user = {
        services = {
          zen-chrome-http-server = {
            Unit.Description = "Simple HTTP Server for ZEN Chrome directory";
            Install.WantedBy = ["xdg-desktop-autostart.target"];

            Service = {
              ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8000";
              WorkingDirectory = "${config.xdg.configHome}/zen/default/chrome";
            };
          };
        };
      };

      qt = {
        kvantum.settings.General.theme = lib.mkForce "matugen";
        qt6ctSettings.Appearance.color_scheme_path = "${config.home.homeDirectory}/.local/share/color-schemes/DankMatugen.colors";
        qt5ctSettings.Appearance.color_scheme_path = "${config.home.homeDirectory}/.local/share/color-schemes/DankMatugen.colors";
      };

      wayland.windowManager.hyprland.settings.source = lib.mkAfter [
        "./dms/colors.conf"
        "./dms/cursor.conf"
        "./dms/layout.conf"
        "./dms/outputs.conf"
        "./dms/windowrules.conf"
      ];

      xdg.configFile = {
        "gtk-3.0/gtk.css".enable = false;
        "gtk-4.0/gtk.css".enable = false;
      };

      services.polkit-gnome.enable = lib.mkForce false;

      programs = {
        ghostty.settings.theme = lib.mkIf config.programs.ghostty.enable (lib.mkForce "dankcolors");
        television.settings.ui.theme = lib.mkIf config.programs.television.enable (lib.mkForce "matugen");
        yazi.theme = lib.mkIf config.programs.yazi.enable (lib.mkForce {});
      };

      home =
        {
          packages = with pkgs; [
            papirus-icon-theme
          ];
        }
        // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
        {
          persistence = {
            "/persistent/cache".directories = [
              ".config/hypr/dms"
            ];
            "/persistent/storage".directories = [
              ".config/matugen"
              ".config/DankMaterialShell"
            ];
          };
        };
    }
    // lib.optionalAttrs (builtins.hasAttr "stylix" options)
    {
      stylix.targets = {
        tmux.colors.enable = false;
        hyprland.colors.enable = false;
      };
    };
}
