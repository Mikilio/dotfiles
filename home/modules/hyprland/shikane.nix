{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.shikane ];
  xdg.configFile."shikane/config.toml".text = # toml
    ''
      [[profile]]
      name = "home-office"

      [[profile.output]]
      enable = false
      match = "eDP-1"

      [[profile.output]]
      enable = true
      search = "/.*"
      mode = "preferred"
      position = "0,0"
      scale = 1.0

      [[profile]]
      name = "pre-eject"

      [[profile.output]]
      enable = true
      match = "eDP-1"
      mode = "preferred"
      position = "0,0"
      scale = 1.0

      [[profile.output]]
      enable = false
      search = "/.*"

      [[profile]]
      name = "default"

      [[profile.output]]
      enable = true
      match = "eDP-1"
      mode = "preferred"
      position = "0,0"
      scale = 1.0
    '';

  systemd.user.services.shikane = {
    Unit = {

      Description = "Shikane Wayland output manager";
      Documentation = "man:shikane(1)";
      # order startup after WM
      After = ["graphical-session.target"];
    };

    Service = {

      Type = "exec";
      # ExecCondition = "/lib/systemd/systemd-xdg-autostart-condition \"wlroots:sway:Wayfire:labwc:Hyprland\" \"\"";
      ExecStart = lib.getExe pkgs.shikane;
      ExecReload = "kill -SIGHUP $MAINPID";
      Restart = "on-failure";
      Slice = "background-graphical.slice";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
