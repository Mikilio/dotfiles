{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "opencode";
    module = self.nixosModules.opencode;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.opencode.port == 4096;
            message = "opencode should listen on its configured port";
          }
          {
            assertion = config.users.users.opencode.isSystemUser;
            message = "opencode should run as a system user";
          }
          {
            assertion = config.systemd.services ? opencode;
            message = "opencode systemd service should be defined";
          }
        ];
      })
    ];
    # The service binds /var/run/docker.sock which doesn't exist in the VM,
    # so check the unit definition instead of waiting for it to start.
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat opencode.service")
    '';
  }
