{
  inputs,
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  imports = [
    ./keybinds.nix
    inputs.dank-pinentry.homeModules.default
  ];

  config =
    {
      systemd.user = {
        sessionVariables = {
          inherit (config.home.sessionVariables) SSH_ASKPASS SUDO_ASKPASS;
        };

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

      wayland.windowManager.hyprland.extraConfig = ''
        require("dms.colors")
        require("dms.outputs")
        require("dms.layout")
        require("dms.cursor")
        require("dms.binds-user")
        require("dms.windowrules")
      '';

      xdg.configFile = {
        "gtk-3.0/gtk.css".enable = false;
        "gtk-4.0/gtk.css".enable = false;
        "matugen/templates".source = ./matugen/templates;
      };

      services.polkit-gnome.enable = lib.mkForce false;

      programs = {
        # gpg-agent's pinentry-program, so home.modules.gpg must not also set
        # services.gpg-agent.pinentry.package.
        dank-pinentry = {
          enable = true;
          configureGpgAgent = true;
          installPlugin = false;
          # auto prefers the terminal whenever one is usable, which draws
          # gpg prompts as a curses TUI inside the requesting terminal. Draw
          # them in the DMS widget instead.
          ui = "dms";
          # Install dank-askpass and point sudo -A and ssh at it, so every
          # password dialog draws in the DMS widget. rosecd reads SSH_ASKPASS
          # for its own askpass use, so this is how rosec reaches it too.
          askpass = {
            enable = true;
            sudo = true;
            ssh = true;
          };
        };

        ghostty.settings.theme = lib.mkIf config.programs.ghostty.enable (lib.mkForce "dankcolors");
        television.settings.ui.theme = lib.mkIf config.programs.television.enable (lib.mkForce "matugen");
        yazi.theme = lib.mkIf config.programs.yazi.enable (lib.mkForce {});
      };

      home =
        {
          packages = with pkgs; [
            papirus-icon-theme
          ];

          # The plugin's DependencyCheck refuses to load without the binary. It
          # probes `command -v dank-pinentry` first, but dms.service runs with
          # a read-only store PATH (nixpkgs sets
          # systemd.user.services.dms.path to []) and does not inherit the
          # home-manager profile, so PATH never resolves. ~/.local/bin is one
          # of the three paths it falls back to.
          file.".local/bin/dank-pinentry" = {
            source = "${config.programs.dank-pinentry.package}/bin/dank-pinentry";
            executable = true;
          };
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
              ".local/share/dankcal"
            ];
          };
        };
    }
    // lib.optionalAttrs (builtins.hasAttr "stylix" options)
    {
      stylix.targets = {
        tmux.colors.enable = false;
        hyprland.colors.enable = false;
        dank-calendar.enable = false;
      };
    };
}
