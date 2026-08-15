{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-neovix";
    module = self.homeModules.neovix;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'command -v neovix'")
        machine.succeed("su - alice -c 'test -n \"$EDITOR\"'")
      '';
  }
