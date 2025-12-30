{
  pkgs,
  config,
  ...
}: {
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  # for hyprlock
  security.pam.services.hyprlock = {};

  services.dbus.packages = with pkgs; [
    xdg-desktop-portal-hyprland
  ];

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
