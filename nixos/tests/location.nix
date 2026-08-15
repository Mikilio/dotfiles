{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "location";
    module = self.nixosModules.location;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.location.provider == "geoclue2";
            message = "location provider should be geoclue2";
          }
          {
            assertion = config.services.geoclue2.enable;
            message = "geoclue2 should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat geoclue.service")
    '';
  }
