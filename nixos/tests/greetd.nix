{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "greetd";
    module = self.nixosModules.greetd;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.rosec.enable;
            message = "rosec should be enabled";
          }
          {
            assertion = config.services.fprintd.enable;
            message = "fprintd should be enabled";
          }
          {
            assertion = config.security.pam.u2f.enable;
            message = "pam u2f should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      # rosecd is a D-Bus activated user daemon, so there is no system unit to
      # wait on; the rosec binary is the visible effect of the module.
      machine.succeed("command -v rosec")
    '';
  }
