{
  pkgs,
  lib,
  options,
  ...
}: {
  imports = [
    ./rosec.nix
  ];
  config = {
    xdg.configFile."rofi-rbw.rc".text = ''
      selector rofi
      clipboarder wl-copy
      typer ydotool
      clear-after 30
      use-notify-send
    '';

    programs = {
      rbw = {
        enable = true;
        settings = {
          # identity_url = lib.mkDefault "https://identity.bitwarden.eu";
          base_url = lib.mkDefault "https://vault.mcloud";
          pinentry = pkgs.pinentry-gnome3;
        };
      };
      password-store = {
        enable = true;
        package = pkgs.pass-wayland.withExtensions (
          exts:
            with exts; [
              pass-otp
              pass-file
              # pass-audit
              pass-update
              pass-import
            ]
        );
      };
    };

    services.rosec = {
      enable = true;
      package = pkgs.nur.repos.mikilio.rosec;
      settings = {
        service = {
          dedup_strategy = "priority";
        };
        autolock = {
          on_session_lock = true;
          idle_timeout_minutes = 5;
        };
        provider = [
          {
            kind = "gnome-keyring";
            id = "gnome-keyring";
            name = "GNOME Keyring";
          }
          {
            id = "personal";
            kind = "bitwarden-pm";
            tls_mode = "system";
            offline_cache = false;
            options = {
              email = "kilian.mio@mikilio.com";
              region = "eu";
              base_url = "https://vault.mcloud";
              allowed_hosts = "*.bitwarden.com, *.bitwarden.eu, vault.mcloud";
            };
          }
          {
            id = "local";
            kind = "local";
            path = "/home/mikilio/.local/share/rosec/vaults/local.vault";
          }
        ];
      };
    };
    # programs.browserpass.enable = true;
    # services.pass-secret-service = {
    #   enable = true;
    #   storePath = "${config.home.homeDirectory}/.local/share/password-store";
    # };
    #
    # systemd.user.services.pass-secret-service.Unit = let
    #   deps = ["gpg-agent.service"];
    # in {
    #   After = deps;
    #   Requires = deps;
    # };

    home =
      {
        packages = with pkgs; [
          rofi-rbw
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/storage" = {
          directories = [
            {
              directory = ".local/share/password-store";
              mode = "0700";
            }
            {
              directory = ".local/share/rbw";
              mode = "0700";
            }
            {
              directory = ".local/share/rosec";
              mode = "0700";
            }
            {
              directory = ".config/Bitwarden";
              mode = "0700";
            }
          ];
        };
      };
  };
}
