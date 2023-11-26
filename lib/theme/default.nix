{
  colorlib,
  lib,
}: rec {
  colors = import ./colors.nix;
  # #RRGGBB
  xcolors = lib.mapAttrs (_: colorlib.x) colors;
  # rgba(,,,) colors (css)
  rgbaColors = lib.mapAttrs (_: colorlib.rgba) colors;

  terminal = {
    font = "JetBrainsMono Nerd Font";
    opacity = 0.9;
    size = 10;
  };

  wallpaper = builtins.fetchurl rec {
    name = "wallpaper-${sha256}.jpg";
    url = "https://w.wallhaven.cc/full/d6/wallhaven-d6vj7g.jpg";
    sha256 = "0wa5wv67diw0pbwjkv8wmag2algmbqdp9qg5k3xhpqbpyfyh4fkh";
  };
}
