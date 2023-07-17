{
  pkgs,
  config,
  ...
}: let
  browser = ["vivaldi.desktop"];
  homeDir = config.home.homeDirectory;

  # XDG MIME types
  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;

    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.dekstop"];
    "image/*" = ["imv.desktop"];
    "application/json" = browser;
    "application/pdf" = ["sioyek.desktop"];
    "x-scheme-handler/discord" = ["discordcanary.desktop"];
    "x-scheme-handler/spotify" = ["spotify.desktop"];
  };
in {
  config.xdg = {
    enable = true;
    cacheHome = homeDir + "/.local/cache";
    configHome = homeDir + "/.config";

    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      documents = "${homeDir}/docs";
      download = "${homeDir}/etc/download";
      music = "${homeDir}/media/music";
      pictures = "${homeDir}/media/pics";
      videos = "${homeDir}/media/videos";
      publicShare = "${homeDir}/etc/public";
      templates = "${homeDir}/temp";
      extraConfig = {
        XDG_DEV_DIR = "${homeDir}/dev";
        XDG_GAMES_DIR = "${homeDir}/games";
        XDG_PRIVATE_DIR = "${homeDir}/etc/private";
        XDG_SCREENSHOTS_DIR = "${homeDir}/media/pics/screenshots";
      };
    };
  };
}
