{ inputs, ... }@fp:
{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.preferences.desktop;

in {

  imports = [
    inputs.gBar.homeManagerModules.x86_64-linux.default
  ];

  config = mkIf (cfg.statusbar == "gBar") {
    

    programs.gBar = {
      enable = true;
      config = {
        LockCommand = null;
        BatteryFolder = null;
        DefaultWorkspaceSymbol = "";
        NumWorkspaces = 5;
        CenterTime = false;
        TimeSpace = 150;
        AudioScrollSpeed = 2;
        NetworkAdapter = "enp5s0";
        SNIIconSize = {};
        SNIIconPaddingTop = {};
        # These set the range for the network widget. The widget changes colors at six intervals:
        #    - Below Min...Bytes ("under")
        #    - Between ]0%;25%]. 0% = Min...Bytes; 100% = Max...Bytes ("low")
        #    - Between ]25%;50%]. 0% = Min...Bytes; 100% = Max...Bytes ("mid-low")
        #    - Between ]50%;75%]. 0% = Min...Bytes; 100% = Max...Bytes ("mid-high")
        #    - Between ]75%;100%]. 0% = Min...Bytes; 100% = Max...Bytes ("high")
        #    - Above Max...Bytes ("over")
        MaxDownloadBytes = 131100000;
        MaxUploadBytes = 42000000;
      };
      extraConfig = ''
        WidgetsRight: [Tray, Audio, Bluetooth, Network, Disk, VRAM, GPU, RAM, CPU]
      '';
    };

    # systemd.user.services.gbar = {
    #   Unit = {
    #       Description = "Blazingly fast status bar written with GTK.";
    #       Documentation = "https://github.com/Alexays/Waybar/wiki";
    #       PartOf = [ "graphical-session.target" ];
    #       After = [ "graphical-session-pre.target" "sound.target"];
    #     };
    #
    #   Service = {
    #     BusName= "org.kde.StatusNotifierWatcher";
    #     ExecStart = "${lib.getExe pkgs.gbar} bar 1";  # open in second monitor
    #     Restart = "on-failure";
    #   };
    # };
    #
    # systemd.user.targets.tray = {
    #   Unit = {
    #     Description = "Home Manager System Tray";
    #     Requires = [
    #       "graphical-session-pre.target"
    #       "gbar.service"
    #       ];
    #   };
    # };
  };
}
