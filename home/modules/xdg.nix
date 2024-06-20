{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  inherit (builtins) concatStringsSep attrNames readDir;
in {
  config = {
    xdg = {
      enable = true;

      dataFile."xdg-terminals".source = "${pkgs."${config.home.sessionVariables.TERM}"}/share/applications";

      configFile."xdg-terminals.list".text = (
        concatStringsSep "\n" (attrNames (
          lib.filterAttrs (entry: type: type == "regular") (
            readDir "${pkgs."${config.home.sessionVariables.TERM}"}/share/applications"
          )
        ))
      );

      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${homeDir}/misc";
        documents = "${homeDir}/docs";
        download = "${homeDir}/misc/download";
        music = "${homeDir}/media/music";
        pictures = "${homeDir}/media/pics";
        videos = "${homeDir}/media/videos";
        publicShare = "${homeDir}/misc/public";
        templates = "${homeDir}/docs/temp";
        extraConfig = {
          XDG_DEV_DIR = "${homeDir}/dev";
          XDG_PRIVATE_DIR = "${homeDir}/misc/private";
          XDG_SCREENSHOTS_DIR = "${homeDir}/media/pics/screenshots";
        };
      };
      #TODO: add preferences so inkscape doen't annoy me
    };

    home.packages = [config.nur.repos.mikilio.xdg-terminal-exec];
  };
}
