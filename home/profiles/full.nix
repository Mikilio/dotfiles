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
        terminal = "wezterm";
        media = true;
        gui = true;
        games = true;
        browser = "vivaldi";
        reader = "sioyek";
        productivity = true;
        passwords = true;
        sync = true;
      };
      desktop = {
        compositor = "hyprland";
        statusbar = "eww";
      };
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
  };
}
