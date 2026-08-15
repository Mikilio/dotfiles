{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "graphics";
    module = self.nixosModules.graphics;
    modules = [
      # ROCm CLR is not needed to verify the module in a headless VM and
      # would make the test build enormous.
      {
        hardware.amdgpu.opencl.enable = lib.mkForce false;
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.hardware.amdgpu.initrd.enable;
            message = "amdgpu initrd support should be enabled";
          }
          {
            assertion = config.hardware.graphics.enable;
            message = "graphics drivers should be enabled";
          }
          {
            assertion = builtins.any (p: (p.pname or "") == "libvdpau-va-gl") config.hardware.graphics.extraPackages;
            message = "extra graphics packages should be present";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("test -d /sys/class/drm")
    '';
  }
