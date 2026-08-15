{
  options,
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.gaming;
in {
  options.gaming.user = lib.mkOption {
    type = lib.types.str;
    default = "gamer";
    description = "User account for gaming.";
  };

  config =
    {
      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          extraCompatPackages = [
            pkgs.proton-ge-bin
          ];

          # fix gamescope inside steam
          package = pkgs.steam;
        };
        gamescope.capSysNice = true;
        gamemode = {
          enable = true;
          settings = {
            general = {
              softrealtime = "auto";
              renice = 15;
            };
          };
        };
      };

      hardware = {
        steam-hardware.enable = true;
      };
      boot.extraModprobeConfig = ''options bluetooth disable_ertm=1 '';

      users.users.${cfg.user} = {
        isNormalUser = true;
        home = "/home/${cfg.user}";
        group = "users";
        extraGroups = [
          "audio"
          "video"
          "gamemode"
        ];
      };
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/cache".directories = [
          "/home/${cfg.user}"
        ];
      };
    }
    // lib.optionalAttrs (options ? home-manager)
    {
      home-manager.users.${cfg.user} = {
        lib,
        pkgs,
        options,
        ...
      }: {
        home =
          {
            packages = [
              pkgs.fjordlauncher
            ];
          }
          // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
          {
            persistence = {
              "/persistent/storage" = {
                directories = [
                  {
                    directory = ".steam";
                    mode = "0755";
                  }
                ];
              };
              "/persistent/cache" = {
                directories = [
                  {
                    directory = ".local/share/Steam";
                    mode = "0755";
                  }
                ];
              };
            };
          };
      };
    };
}
