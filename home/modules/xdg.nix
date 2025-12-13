{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  config = {
    qt = {
      qt5ctSettings.Appearance.standard_dialogs = "xdgdesktopportal";
      qt6ctSettings.Appearance.standard_dialogs = "xdgdesktopportal";
    };

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
  };
}
