{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-rofi";
    module = self.homeModules.rofi;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'rofi -version'")
        machine.succeed("su - alice -c 'command -v rofimoji'")
        machine.succeed("su - alice -c 'test -f ~/.config/rofi/config.rasi'")
      '';
  }
