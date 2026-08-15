{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "thunderbolt";
    module = self.nixosModules.thunderbolt;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = builtins.elem "thunderbolt" config.boot.kernelModules;
            message = "thunderbolt kernel module should be loaded";
          }
          {
            assertion = config.services.hardware.bolt.enable;
            message = "bolt should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat bolt.service")
    '';
  }
