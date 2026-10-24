{
  inputs,
  pkgs,
  lib,
  options,
  config,
  ...
}: let
  # Home-manager validates ~/.config/ghostty/config at activation by running
  # `ghostty +validate-config`. That config sets `theme = dankcolors`, but dux
  # only generates themes/dankcolors at runtime (dux matugen), so at activation
  # the theme does not exist and validation fails, breaking
  # home-manager-*.service on every boot before dux has ever run.
  #
  # ghostty has no fallback-theme option and treats a missing named theme as a
  # hard error, so the only way to tolerate it without also home-managing the
  # theme (which would clobber dux's live colors on every activation) is to
  # validate everything except the missing-theme error. ghostty prints that
  # error as `theme "<name>" not found, tried path "..."`, which never starts
  # with the config path, whereas real errors are `<config>:<line>:...`.
  ghosttyConfigValidator = pkgs.writeShellApplication {
    name = "ghostty-config-validate-allow-missing-theme";
    runtimeInputs = [config.programs.ghostty.package];
    text = ''
      config_file="$1"
      if output=$(ghostty +validate-config --config-file="$config_file" 2>&1); then
        exit 0
      fi

      # Drop missing-theme notices; anything left is a real validation error.
      real_errors=$(printf '%s\n' "$output" | grep -v '^theme ".*" not found, tried path ' || true)
      if [ -n "$real_errors" ]; then
        printf '%s\n' "$real_errors" >&2
        exit 1
      fi
    '';
  };
in {
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
        require("dux.colors")
        require("dux.outputs")
        require("dux.layout")
        require("dux.cursor")
        require("dux.binds-user")
        require("dux.windowrules")
      '';

      xdg.configFile =
        {
          "gtk-3.0/gtk.css".enable = false;
          "gtk-4.0/gtk.css".enable = false;
          "matugen/templates".source = ./matugen/templates;
        }
        // lib.optionalAttrs config.programs.ghostty.enable {
          # Tolerate `theme = dankcolors` not existing yet (dux generates it at
          # runtime); see ghosttyConfigValidator above.
          "ghostty/config".onChange = lib.mkForce "${lib.getExe ghosttyConfigValidator} ${config.xdg.configHome}/ghostty/config";
        };

      # .ics files open in Dank Calendar.
      xdg.mimeApps.defaultApplications."text/calendar" = "com.danklinux.dankcalendar.desktop";

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
          # them in the dux widget instead.
          ui = "dux";
          # Install dank-askpass and point sudo -A and ssh at it, so every
          # password dialog draws in the dux widget. rosecd reads SSH_ASKPASS
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
          # probes `command -v dank-pinentry` first, but dux.service runs with
          # a read-only store PATH (nixpkgs sets
          # systemd.user.services.dux.path to []) and does not inherit the
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
              ".config/hypr/dux"
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
