{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-email";
    module = self.homeModules.email;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'thunderbird --version'")
      '';
  }
