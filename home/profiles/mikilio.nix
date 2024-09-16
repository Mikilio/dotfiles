{
  config,
  options,
  lib,
  pkgs,
  ezModules,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    anyrun
    cli
    email
    foot
    firefox
    floorp
    gpg
    games
    git
    hyprshell
    hyprland
    media
    nushell
    # nvim
    neovix
    pass
    pipewire
    productivity
    sioyek
    spicetify
    ssh
    starship
    theming
    tmux
    transient-services
    xdg
    yazi
  ];

  config = {
    home = {
      username = "mikilio";
      homeDirectory = osConfig.users.users.mikilio.home;
      extraOutputsToInstall = ["doc" "devdoc"];
    };

    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = ../../secrets/user/mikilio.yaml;
      secrets =
        builtins.mapAttrs (
          name: value:
            value // {path = "${config.xdg.userDirs.extraConfig.XDG_PRIVATE_DIR}/secrets/${name}";}
        ) {
          google-git = {};
        };
    };
  };
}
