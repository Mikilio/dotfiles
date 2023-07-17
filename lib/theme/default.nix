{
  colorlib,
  lib,
}: rec {
  colors = import ./colors.nix;
  # #RRGGBB
  xcolors = lib.mapAttrs (_: colorlib.x) colors;
  # rgba(,,,) colors (css)
  rgbaColors = lib.mapAttrs (_: colorlib.rgba) colors;

  browser = "vivaldi";

  launcher = "anyrun";

  terminal = {
    font = "JetBrainsMono Nerd Font";
    name = "alacritty";
    opacity = 0.9;
    size = 10;
  };

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.png";
    url = "https://w.wallhaven.cc/full/p9/wallhaven-p9yp3e.jpg";
    sha256 = "1vg35hwa4yvwa3pmb9ahh0x8v9p4zw785s57gjbis7h7cwwfb60l";
  };
}
