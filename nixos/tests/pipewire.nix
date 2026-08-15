{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "pipewire";
    module = self.nixosModules.pipewire;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.pipewire.enable;
            message = "pipewire should be enabled";
          }
          {
            assertion = config.services.pipewire.wireplumber.enable;
            message = "wireplumber should be enabled";
          }
          {
            assertion = builtins.elem "v4l2loopback" config.boot.kernelModules;
            message = "v4l2loopback should be loaded";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("test -e /run/current-system/sw/bin/pipewire")
    '';
  }
