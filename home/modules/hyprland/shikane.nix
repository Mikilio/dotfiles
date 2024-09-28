{ pkgs, ... }:
{
  home.packages = [ pkgs.shikane ];
  xdg.configFile."shikane/config.toml".text = # toml
    ''
        [[profile]]
        name = "home-office"
        exec = ["systemctl --user restart hyprshell"]

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
        name = "laptop"
        exec = ["systemctl --user restart hyprshell"]

        [[profile.output]]
        enable = true
        match = "eDP-1"
        scale = 1.2
        position = "0,0"
    '';

  systemd.user.services.shikane =
    let
      systemdTarget = "graphical-session.target";

    in
    {
      Unit = {
        Description = "Dynamic output configuration";
        Documentation = "man:shikane(1)";
        PartOf = systemdTarget;
        After = systemdTarget;
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.shikane}/bin/shikane";
        Restart = "always";
      };

      Install = {
        WantedBy = [ systemdTarget ];
      };
    };
}
