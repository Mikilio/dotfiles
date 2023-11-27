
{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.preferences.desktop;

in {
  config = mkIf (cfg.statusbar == "gBar") {
    

    programs.gBar = {
      enable = true;
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [
          "graphical-session-pre.target"
          "gbar.service"
          ];
      };
    };
  };
}
