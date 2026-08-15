{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "security";
    module = self.nixosModules.security;
    modules = [
      {
        dotfiles.security.target = "desktop";
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.security.tpm2.enable;
            message = "tpm2 should be enabled";
          }
          {
            assertion = config.services.usbguard.enable;
            message = "usbguard should be enabled";
          }
          {
            assertion = config.services.clamav.daemon.enable;
            message = "clamav daemon should be enabled";
          }
          {
            assertion = config.programs.firejail.wrappedBinaries ? thunderbird;
            message = "thunderbird should be wrapped in firejail";
          }
          {
            assertion = config.security.sudo.execWheelOnly;
            message = "sudo should be wheel-only";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat usbguard.service")
      machine.succeed("systemctl cat clamav-daemon.service")
    '';
  }
