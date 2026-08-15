{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "power";
    module = self.nixosModules.power;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.power-profiles-daemon.enable;
            message = "power-profiles-daemon should be enabled";
          }
          {
            assertion = config.services.upower.enable;
            message = "upower should be enabled";
          }
          {
            assertion = config.services.logind.settings.Login.HandlePowerKey == "suspend";
            message = "power key should suspend";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      # power-profiles-daemon and upower are D-Bus activated in this nixpkgs,
      # so they never run on their own in a headless VM; the shipped unit files
      # are the runtime confirmation that the module wired them up.
      machine.succeed("systemctl cat power-profiles-daemon.service")
      machine.succeed("systemctl cat upower.service")
    '';
  }
