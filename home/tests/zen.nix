{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation allowUnfree;
in
  mkHomeTest {
    name = "home-zen";
    module = self.homeModules.zen;
    modules = [
      nurAccommodation
      allowUnfree
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'zen-beta --version'")
      '';
  }
