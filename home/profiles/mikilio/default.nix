{
  config,
  options,
  lib,
  pkgs,
  ezModules,
  osConfig,
  ...
}:
{
  imports = with ezModules; [
    anyrun
    cli
    email
    foot
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
      extraOutputsToInstall = [
        "doc"
        "devdoc"
      ];
    };

    programs = {
      gpg.publicKeys = [
        {
          source = ./gmail_mikilio.asc;
          trust = 5;
        }
      ];
    };

    pam.yubico.authorizedYubiKeys.ids = [ "cccccbhkevjb" ];

    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = ../../../secrets/user/mikilio.yaml;
      secrets = {
        google-git = { };
      };
    };
    systemd.user.services.sops-nix = {
      Install = {
        WantedBy = lib.mkForce [ "graphical-session.target" ];
      };
      Unit = {
        After = "graphical-session.target";
        Before = "xdg-desktop-autostart.target";
      };
    };

  };
}
