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
    imv
    mpv
    xfce.thunar-full
    xarchiver
    vivaldi
    neovim
  ];
  cfg = config.preferences.apps.terminal;

in {
  config = mkIf (!isNull cfg) {
    xdg = {
      enable = true;

      mimeApps = {
        enable = true;
        defaultApplications = mkMerge (map config.lib.xdg.mimeAssociations defaultApps);
      };

      dataFile."xdg-terminals".source = "${pkgs."${config.home.sessionVariables.TERM}"}/share/applications";

      configFile."xdg-terminals.list".text = with builtins; (
        concatStringsSep "\n" (attrNames (
          filterAttrs (entry: type: type == "regular") (
            readDir "${pkgs."${config.home.sessionVariables.TERM}"}/share/applications"
          )
        ))
      );

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

    home.packages = [ config.nur.repos.mikilio.xdg-terminal-exec ];
  };
}
