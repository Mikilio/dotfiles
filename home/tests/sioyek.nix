{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-sioyek";
    module = self.homeModules.sioyek;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'sioyek --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/sioyek/prefs.config'")
      '';
  }
