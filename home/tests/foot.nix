{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-foot";
    module = self.homeModules.foot;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'foot --version'")
        machine.succeed("su - alice -c 'footclient --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/foot/foot.ini'")
      '';
  }
