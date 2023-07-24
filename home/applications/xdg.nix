{
  lib,
  pkgs,
  config,
  ...
}:
with lib;

let
  browser = ["vivaldi.desktop"];
  homeDir = config.home.homeDirectory;

  defaultApps = with pkgs; [
    vivaldi imv mpv xfce.thunar
    xarchiver
  ];

in {

  config.xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = mkMerge (map config.lib.xdg.mimeAssociations defaultApps);
    };

    configFile."xdg-terminals.list".text = ''
      Alacritty.desktop
    '';

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${homeDir}/etc/misc";
      documents = "${homeDir}/docs";
      download = "${homeDir}/etc/download";
      music = "${homeDir}/media/music";
      pictures = "${homeDir}/media/pics";
      videos = "${homeDir}/media/videos";
      publicShare = "${homeDir}/etc/public";
      templates = "${homeDir}/docs/temp";
      extraConfig = {
        XDG_DEV_DIR = "${homeDir}/dev";
        XDG_PRIVATE_DIR = "${homeDir}/etc/private";
        XDG_SCREENSHOTS_DIR = "${homeDir}/media/pics/screenshots";
      };
    };
  };
}
