{
  config,
  options,
  lib,
  pkgs,
  localModules,
  ...
}:
with lib; let
  apps = with localModules.applications; [
    spicetify
    media
    qt
    xdg
    sioyek
    firefox
    gpg
    games
    gtk
    wezterm
    productivity
    keepassxc
  ];
  terminal = with localModules.terminal; [
    starship
    nushell
    git
    cli
    nvim
    yazi
    calendar
    ssh
    # pass
  ];
  wayland = with localModules.wayland; [
    ags
    hyprland
    pipewire
  ];
in {
  imports = apps ++ terminal ++ wayland;

  config = {
    home = {
      username = "mikilio";
      homeDirectory = "/home/mikilio";
      stateVersion = "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];
    };

    home.sessionVariables.TERM = "wezterm";

    xdg.configFile = {
      "autostart/org.wezfurlong.wezterm.desktop".source = "${config.programs.wezterm.package}/share/applications/org.wezfurlong.wezterm.desktop";
    };

    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = ../../secrets/groups/mikilio.yaml;
      secrets =
        builtins.mapAttrs (
          name: value:
            value // {path = "${config.xdg.userDirs.extraConfig.XDG_PRIVATE_DIR}/secrets/${name}";}
        ) {
          google-git = {};
          spotify_pwd.key = "spotify/pwd";
          spotify_usr.key = "spotify/usr";
          keepassxc = {};
          google-cal_id.key = "google-cal/id";
          google-cal_secret.key = "google-cal/secret";
        };
    };
  };
}
