{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-zathura";
    module = self.homeModules.zathura;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'zathura --version'")
      '';
  }
