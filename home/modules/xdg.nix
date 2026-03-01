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
            DEV= "${homeDir}/Code";
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
