{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation allowUnfree;
in
  mkHomeTest {
    name = "home-floorp";
    module = self.homeModules.floorp;
    modules = [
      nurAccommodation
      allowUnfree
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'floorp --version'")
      '';
  }
