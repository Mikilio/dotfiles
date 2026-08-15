{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation;
in
  mkHomeTest {
    name = "home-zus";
    module = self.homeModules.zus;
    modules = [nurAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'zus --version'")
      '';
  }
