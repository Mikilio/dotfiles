{
  config,
  options,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  config =
    {
      xdg = {
        enable = true;

        userDirs = {
          enable = true;
          createDirectories = true;
          extraConfig = {
            XDG_DEV_DIR = "${homeDir}/Code";
          };
        };

        terminal-exec.enable = true;

        mimeApps = {
          enable = true;
        };
      };
    }
    // lib.optionalAttrs (builtins.hasAttr "stylix" options)
    {
      stylix.targets.qt.standardDialogs = "xdgdesktopportal";
    };
}
