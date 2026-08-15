{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-waybar";
    module = self.homeModules.waybar;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'waybar --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/waybar/config'")
        machine.succeed("su - alice -c 'test -f ~/.config/waybar/style.css'")
      '';
  }
