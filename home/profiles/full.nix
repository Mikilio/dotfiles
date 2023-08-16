{
  config,
  options,
  lib,
  pkgs,
  flakePath,
  ...
}:
with lib; let
in {
  config = {
    home = {
      username = "mikilio";
      homeDirectory = "/home/mikilio";
      stateVersion = "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];
      sessionVariables = {
        # clean up ~
        LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
        LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";
        WINEPREFIX = "$XDG_DATA_HOME/wine";
        XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

        # enable scrolling in git diff
        DELTA_PAGER = "less -R";

        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        DIRENV_LOG_FORMAT = "";
        GDK_SCALE = "2";
      };

      sessionPath = ["$HOME/.local/bin"];
    };

    preferences = {
      cli = {
        shell = "zsh";
        starship = true;
        joshuto = true;
        editor = "neovim";
      };
      apps = {
        terminal = "alacritty";
        media = true;
        gui = true;
        games = true;
        browser = "vivaldi";
        reader = "sioyek";
        productivity = true;
        passwords = true;
        sync = true;
      };
      desktop = "hyprland";
    };

    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = "${flakePath}/secrets/groups/mikilio.yaml";
      secrets =
        builtins.mapAttrs (
          name: value:
            value // {path = "${config.xdg.userDirs.extraConfig.XDG_PRIVATE_DIR}/secrets/${name}";}
        ) {
          google-git = {};
          spotify_pwd.key = "spotify/pwd";
          spotify_usr.key = "spotify/usr";
          keepassxc = {};
        };
    };
    systemd.user.services.sops-nix.Install.WantedBy = lib.mkForce ["graphical-session.target"];
  };
}
