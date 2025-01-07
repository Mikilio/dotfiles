{
  config,
  pkgs,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  inherit (builtins) concatStringsSep attrNames readDir;
in
{
  config = {
    xdg = {
      enable = true;

      dataFile."xdg-terminals".source = "${
        pkgs."${config.home.sessionVariables.TERM}"
      }/share/applications";

      configFile."xdg-terminals.list".text = (
        concatStringsSep "\n" (
          attrNames (
            lib.filterAttrs (entry: type: type == "regular") (
              readDir "${pkgs."${config.home.sessionVariables.TERM}"}/share/applications"
            )
          )
        )
      );

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_DEV_DIR = "${homeDir}/Code";
          XDG_SCREENSHOTS_DIR = "${homeDir}/Pictures/screenshots";
        };
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "sioyek.desktop" ];
        };
      };
    };

    xdg.configFile."mimeapps.list".force = true;
    home.packages = [ pkgs.nur.repos.mikilio.xdg-terminal-exec ];
  };
}
