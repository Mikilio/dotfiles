{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "home-manager";
    module = self.nixosModules.home-manager;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.home-manager.useGlobalPkgs;
            message = "home-manager should use global pkgs";
          }
          {
            assertion = config.home-manager.useUserPackages;
            message = "home-manager should use user packages";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
