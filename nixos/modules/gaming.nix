{
  options,
  lib,
  pkgs,
  ...
}: {
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
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/cache".directories = [
          "/home/gamer"
        ];
      };
    };
}
