{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript allowUnfree;
in
  mkHomeTest {
    name = "home-productivity";
    module = self.homeModules.productivity;
    modules = [allowUnfree];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'task --version'")
        machine.succeed("su - alice -c 'command -v taskwarrior-tui'")
        machine.succeed("su - alice -c 'obsidian --version'")
        machine.succeed("su - alice -c 'command -v libreoffice'")
        machine.succeed("su - alice -c 'command -v calibre'")
      '';
  }
