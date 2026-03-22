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
            DEV = "${homeDir}/Code";
          };
        };
        portal = {
          enable = true;
          config = {
            common = {
              default = "*";
            };
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
    }
    // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
    {
      home.persistence."/persistent/storage" = {
        directories = [
          {
            directory = "Pictures";
            mode = "0755";
          }
          {
            directory = "Videos";
            mode = "0755";
          }
          {
            directory = "Music";
            mode = "0755";
          }
          {
            directory = "Desktop";
            mode = "0755";
          }
          {
            directory = ".config";
            mode = "0700";
          }
          {
            directory = "Documents";
            mode = "0755";
          }
          {
            directory = "Code";
            mode = "0755";
          }
          {
            directory = ".config/autostart";
            mode = "0755";
          }
          {
            directory = ".local/share/applications";
            mode = "0755";
          }
        ];
      };
      home.persistence."/persistent/cache" = {
        directories = [
          {
            directory = "Downloads";
            mode = "0700";
          }
        ];
      };
    };
}
