{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-dunst";
    module = self.homeModules.dunst;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'dunst --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/dunst/dunstrc'")
      '';
  }
