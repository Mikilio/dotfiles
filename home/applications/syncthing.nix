{
  config,
  lib,
  pkgs,
  flakePath,
  ...
}:
with lib; let
  cfg = config.home.applications;
in {
  config = mkIf cfg.sync {

    services.syncthing = {
      enable = true;
      extraOptions = [];
      tray = {
        enable = true;
        package = pkgs.syncthing-tray;
      };
    };
  };
}
