{
  pkgs,
  config,
  lib,
  inputs',
  ...
}:
with lib; let
  cfg = config.home.applications;
  steam_compat_path = ".steam/root/compatibilitytools.d";
  # games
in {
  config = mkIf (cfg != null && cfg.games) {
    home.packages = with pkgs; [
      inputs'.nix-gaming.packages.osu-lazer-bin
      inputs'.nix-gaming.packages.wine-discord-ipc-bridge
      inputs'.nix-gaming.packages.wine-ge
      # (lutris.override {extraPkgs = p: [p.libnghttp2];})
      gamescope
      winetricks
    ];
  };
}
