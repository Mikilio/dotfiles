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
        enable = false; # TODO make true when you have a system tray
        package = pkgs.syncthing-tray;
      };
    };
  };
}
