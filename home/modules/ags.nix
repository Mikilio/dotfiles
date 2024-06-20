{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.hyprshell.packages.${pkgs.stdenv.system}.default
  ];

  services = {
    network-manager-applet.enable = true;
    copyq = {
      enable = true;
      systemdTarget = "hyprland-session.target";
    };
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = ["hyprshell -b hypr"];
  };
}
