{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-pandoc";
    module = self.homeModules.pandoc;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'pandoc --version'")
        machine.succeed("su - alice -c 'command -v lualatex'")
        machine.succeed("su - alice -c 'test -f ~/.config/pandoc/defaults.yaml'")
      '';
  }
