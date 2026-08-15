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
        machine.succeed("su - alice -c 'wpctl status'")
        machine.succeed("su - alice -c 'command -v wireplumber'")
        machine.wait_for_unit("wireplumber.service", "alice")
      '';
  }
