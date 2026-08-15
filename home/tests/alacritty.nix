{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-alacritty";
    module = self.homeModules.alacritty;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'alacritty --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/alacritty/alacritty.toml'")
      '';
  }
