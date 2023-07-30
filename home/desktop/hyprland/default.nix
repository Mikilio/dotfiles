{
  inputs',
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.home.desktop;
in {
  imports = [
    ./config.nix
  ];

  config = mkIf (cfg == "hyprland") {
    home.packages = with pkgs; [
      jaq
      xorg.xprop
      inputs'.hyprland-contrib.packages.grimblast
    ];

    programs.eww-hyprland = {
      enable = true;

      # default package
      package = pkgs.eww-wayland;

      # set to true to reload on change
      autoReload = false;
    };
    # start swayidle as part of hyprland, not sway
    systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

    xdg.configFile."Hyprland-xdg-terminals.list".text = "";

    # enable hyprland
    wayland.windowManager.hyprland.enable = true;
  };
}
