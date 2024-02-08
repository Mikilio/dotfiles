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
    spicetify media qt xdg
    sioyek firefox gpg games gtk
    wezterm productivity keepassxc
  ];
shell = with localModules.shell; [
    starship nushell git cli nvim bash
  ];
desktop = with localModules.desktop; [
    ags hyprland swayidle pipewire
  ];

in {

  imports = apps ++ shell ++ desktop;

  config = {
    home = {
      username = "mikilio";
      homeDirectory = "/home/mikilio";
      stateVersion = "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];

      sessionPath = ["$HOME/.local/bin"];
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
        };
    };
  };
}
