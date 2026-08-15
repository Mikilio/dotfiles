{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-wezterm";
    module = self.homeModules.wezterm;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'wezterm --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/wezterm/wezterm.lua'")
      '';
  }
