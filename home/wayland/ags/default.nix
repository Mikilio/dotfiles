{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      inputs'.asztal.packages.default
    ];

    wayland.windowManager.hyprland.settings = {
      exec-once = ["asztal -b hypr"];
    };
  }
)
