{
  config,
  pkgs,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  config = {
    xdg = {
      enable = true;

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_DEV_DIR = "${homeDir}/Code";
        };
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = ["sioyek.desktop"];
          "text/html" = ["floorp.desktop"];
          "x-scheme-handler/http" = ["floorp.desktop"];
          "x-scheme-handler/https" = ["floorp.desktop"];
          "inode/directory" = ["yazi.desktop"];
        };
      };
    };

    xdg.configFile."mimeapps.list".force = true;
    home.packages = [pkgs.nur.repos.mikilio.xdg-terminal-exec];
  };
}
