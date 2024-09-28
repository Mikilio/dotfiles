{
  inputs,
  pkgs,
  ...
}:
{

  #fix portals
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # enable hyprland and required options
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    # make HM-managed GTK stuff work
    dconf.enable = true;

    ydotool.enable = true;

    kdeconnect.enable = true;
  };
}
