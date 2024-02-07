{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib; let

in {
  config = {
    home.packages = with pkgs; [
      # inputs'.nix-gaming.packages.osu-lazer-bin
      # inputs'.nix-gaming.packages.star-citizen
      inputs'.nix-gaming.packages.wine-discord-ipc-bridge
      # inputs'.nix-gaming.packages.proton-ge
      # (lutris.override {extraPkgs = p: [p.libnghttp2 p.jansson ];})
      gamescope
      wine
      winetricks
    ];
  };
})
