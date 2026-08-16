{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-pipewire";
    module = self.homeModules.pipewire;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'test -f ~/.config/pipewire/pipewire.conf.d/10-obs.conf'")
        machine.succeed("su - alice -c 'command -v easyeffects'")
      '';
  }
