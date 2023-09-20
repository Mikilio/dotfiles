{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
in {
  config = mkIf cfg.sync {

    services.syncthing = {
      enable = true;
      extraOptions = [];
    };
    
    home.packages = [
      pkgs.syncthingtray
    ];
  };
}
