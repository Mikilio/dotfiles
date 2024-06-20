{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  hyprlandSessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
      [Desktop Entry]
      Name=Hyprland
      Comment=A dynamic tiling Wayland compositor that doesn't sacrifice on its looks
      Exec=${pkgs.hyprland}/bin/Hyprland
      Type=Application
    '')
    .overrideAttrs (_: {passthru.providedSessions = ["hyprland"];});
in {
  #everything necessary to have hyprland work properly
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  #fix portals
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  #Qt styling
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  environment.variables.NIXOS_OZONE_WL = "1";

  # enable hyprland and required options
  programs = {
    hyprland.enable = true;

    # make HM-managed GTK stuff work
    dconf.enable = true;

    ydotool.enable = true;

    kdeconnect.enable = true;
  };

  services.displayManager.sessionPackages = [hyprlandSessionFile];
}
