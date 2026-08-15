{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "vm-dev";
    module = self.nixosModules.vm-dev;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.programs.virt-manager.enable;
            message = "virt-manager should be enabled";
          }
          {
            assertion = config.virtualisation.libvirtd.enable;
            message = "libvirtd should be enabled";
          }
          {
            assertion = config.virtualisation.containers.enable;
            message = "containers should be enabled";
          }
          {
            assertion = config.virtualisation.podman.enable;
            message = "podman should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("libvirtd.service")
      machine.succeed("command -v podman")
    '';
  }
