{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "plymouth";
    module = self.nixosModules.plymouth;
    modules = [
      ({
        config,
        lib,
        ...
      }: {
        # test-instrumentation.nix sets its own console log level; keep the
        # quiet-boot level the module requests.
        boot.consoleLogLevel = lib.mkForce 0;
        assertions = [
          {
            assertion = config.boot.plymouth.enable;
            message = "plymouth should be enabled";
          }
          {
            assertion = config.boot.initrd.systemd.enable;
            message = "initrd systemd should be enabled";
          }
          {
            assertion = config.hardware.amdgpu.initrd.enable;
            message = "amdgpu early KMS should be enabled for native-resolution boot";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
