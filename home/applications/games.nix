{
  pkgs,
  config,
  lib,
  inputs',
  ...
}:

with lib;

let
  cfg = config.home.applications;
# games
in {
  config = mkIf (cfg!=null && cfg.games) {
    home.packages = with pkgs; [
      inputs'.nix-gaming.packages.osu-lazer-bin
      gamescope
      # (lutris.override {extraPkgs = p: [p.libnghttp2];})
      winetricks
    ];
  };
}
