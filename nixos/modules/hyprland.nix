{
  lib,
  pkgs,
  options,
  config,
  ...
}: {
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  # Hardware video decode for the Wayland desktop: VA-API via Mesa, with the
  # VDPAU/VA-API bridge so older players can still use it. nixos-facter only
  # enables hardware.graphics (the driver); these userspace libs are ours.
  hardware.graphics.extraPackages = with pkgs; [
    libva
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  # for hyprlock
  security.pam.services.hyprlock = {};

  services = {
    dbus.packages = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
    displayManager = {
      defaultSession = "hyprland-uwsm";
      dux-greeter = {
        compositor = {
          name = "hyprland";
          customConfig = ''
            env = DMS_RUN_GREETER,1

            misc {
                disable_hyprland_logo = true
            }
          '';
        };
        configHome = lib.mkIf (options?home-manager && (builtins.attrNames config.home-manager.users) != []) "/home/${
          builtins.head (builtins.attrNames config.home-manager.users)
        }";
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
