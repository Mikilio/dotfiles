
{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let
  homeDir = config.home.homeDirectory;

in {
  config = {
    xdg = {
      enable = true;

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
    };

    home.packages = [ config.nur.repos.mikilio.xdg-terminal-exec ];

  };
})
