{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.asztal.packages.${stdenv.system}.default
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = ["asztal -b hypr"];
  };
}
