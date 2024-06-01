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
    spicetify media xdg sioyek
    firefox gpg games theming wezterm
    productivity starship nushell git cli
    nvim yazi calendar ssh pass
    ags hyprland pipewire
  ];

  config = {
    home = {
      username = "mikilio";
      homeDirectory = osConfig.users.users.mikilio.home;
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
      defaultSopsFile = ../../secrets/user/mikilio.yaml;
      secrets =
        builtins.mapAttrs (
          name: value:
            value // {path = "${config.xdg.userDirs.extraConfig.XDG_PRIVATE_DIR}/secrets/${name}";}
        ) {
          google-git = {};
          spotify_pwd.key = "spotify/pwd";
          spotify_usr.key = "spotify/usr";
          keepassxc = {};
          nextcloud = {};
        };
    };
  };
}
