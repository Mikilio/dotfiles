{ inputs'}:
{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
  steam_compat_path = ".steam/root/compatibilitytools.d";
  # games
in {
  config = mkIf (cfg != null && cfg.games) {
    home.packages = with pkgs; [
      inputs'.nix-gaming.packages.osu-lazer-bin
      inputs'.nix-gaming.packages.wine-discord-ipc-bridge
      inputs'.nix-gaming.packages.wine-ge
      lutris
      gamescope
      winetricks
    ];
  };
}
