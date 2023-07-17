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
      applications.enable = true;
    };
    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = "${flakePath}/secrets/groups/mikilio.yaml";
      secrets = builtins.mapAttrs (name: value:
        value // {path = "${config.xdg.userDirs.extraConfig.XDG_PRIVATE_DIR}/secrets/${name}";}
      ) {
        google-git = { };
        spotify_pwd.key  = "spotify/pwd";
        spotify_usr.key = "spotify/usr";

      };
    };
    systemd.user.services.sops-nix.Install.WantedBy = lib.mkForce ["graphical-session.target"];
  };
}
