{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  config = {
    home.packages = with pkgs; [
      # inputs.nix-gaming.packages.${pkgs.stdenv.system}.osu-lazer-bin
      # inputs.nix-gaming.packages.${pkgs.stdenv.system}.star-citizen
      # inputs.nix-gaming.packages.${pkgs.stdenv.system}.wine-discord-ipc-bridge
      # inputs.nix-gaming.packages.${pkgs.stdenv.system}.proton-ge
      # (lutris.override {extraPkgs = p: [p.libnghttp2 p.jansson ];})
      wine
      winetricks
    ];
  };
}
