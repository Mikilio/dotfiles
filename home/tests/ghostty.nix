{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-ghostty";
    module = self.homeModules.ghostty;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'ghostty --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/ghostty/config'")
      '';
  }
