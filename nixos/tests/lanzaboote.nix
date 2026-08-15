{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "lanzaboote";
    module = self.nixosModules.lanzaboote;
    modules = [
      {
        virtualisation.useEFIBoot = true;
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.boot.lanzaboote.enable;
            message = "lanzaboote should be enabled";
          }
          {
            assertion = config.boot.loader.systemd-boot.enable == false;
            message = "systemd-boot should be delegated to lanzaboote";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
