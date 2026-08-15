{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "impermanence";
    module = self.nixosModules.impermanence;
    modules = [
      (import inputs.sops-nix.nixosModules.sops)
      ({
        config,
        lib,
        ...
      }: {
        # The test framework replaces `fileSystems` with `virtualisation.fileSystems`
        # (mkVMOverride), so the persistent mounts must go there. Consequently the
        # `neededForBoot` the module declares cannot be asserted on inside the VM.
        virtualisation.fileSystems."/persistent/storage" = {
          device = "tmpfs";
          fsType = "tmpfs";
          neededForBoot = true;
        };
        virtualisation.fileSystems."/persistent/cache" = {
          device = "tmpfs";
          fsType = "tmpfs";
          neededForBoot = true;
        };
        virtualisation.fileSystems."/persistent/volatile" = {
          device = "tmpfs";
          fsType = "tmpfs";
          neededForBoot = true;
        };

        # In a test VM there is no btrfs + LUKS setup, so disable the initrd
        # rollback service that depends on it.
        boot.initrd.systemd.services.rollback = {
          wantedBy = lib.mkForce [];
          after = lib.mkForce [];
          before = lib.mkForce [];
        };

        assertions = [
          {
            assertion = config.environment.persistence."/persistent/storage".enable;
            message = "persistent storage should be enabled";
          }
          {
            assertion = config.environment.persistence."/persistent/cache" ? directories;
            message = "persistent cache should declare directories";
          }
          {
            assertion = config.services.userborn.enable;
            message = "userborn should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("mountpoint /persistent/storage")
    '';
  }
