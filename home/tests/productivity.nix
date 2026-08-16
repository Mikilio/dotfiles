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
        machine.succeed("su - alice -c 'command -v libreoffice'")
        machine.succeed("su - alice -c 'command -v obsidian'")
        machine.succeed("su - alice -c 'command -v Telegram'")
        machine.succeed("su - alice -c 'command -v element-desktop'")
        machine.succeed("su - alice -c 'command -v zotero'")
      '';
  }
