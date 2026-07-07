{
  pkgs,
  config,
  ...
}: {
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  # for hyprlock
  security.pam.services.hyprlock = {};

  services = {
    dbus.packages = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
    displayManager = {
      defaultSession = "hyprland-uwsm";
      dms-greeter = {
        compositor = {
          name = "hyprland";
          customConfig = ''
            env = DMS_RUN_GREETER,1

            misc {
                disable_hyprland_logo = true
            }
          '';
        };
      };
    };
  };

  # enable hyprland and required options
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };

    iio-hyprland.enable = true;

    ydotool.enable = true;
  };
}
