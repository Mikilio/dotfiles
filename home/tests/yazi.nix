{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation;
in
  mkHomeTest {
    name = "home-yazi";
    module = self.homeModules.yazi;
    modules = [nurAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'yazi --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/yazi/yazi.toml'")
      '';
  }
