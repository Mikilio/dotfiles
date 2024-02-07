{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let

in {
  config = {
    

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = builtins.fromJSON (readFile ./settings.json);
      };
      style = ./style.css;
    };

    systemd.user.services.waybar = {
      Unit = {
          Description =
            "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session-pre.target" "sound.target"];
        };

      Service = {
        BusName= "org.kde.StatusNotifierWatcher";
        ExecStart = lib.getExe pkgs.waybar;
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        KillMode = "mixed";
      };
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [
          "graphical-session-pre.target"
          "waybar.service"
          ];
      };
    };
  };
})
