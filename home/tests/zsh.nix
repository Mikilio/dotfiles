{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-zsh";
    module = self.homeModules.zsh;
    homeModules = [
      self.homeModules.cli
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'zsh --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/zsh/.zshrc'")
      '';
  }
