{ inputs'}:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let

  cfg = config.preferences.apps;

in {
  config = mkIf (cfg != null && cfg.games) {
    home.packages = with pkgs; [
      inputs'.nix-gaming.packages.osu-lazer-bin
      # inputs'.nix-gaming.packages.star-citizen
      inputs'.nix-gaming.packages.wine-discord-ipc-bridge
      inputs'.nix-gaming.packages.proton-ge
      lutris
      gamescope
      winetricks
    ];
  };
}
