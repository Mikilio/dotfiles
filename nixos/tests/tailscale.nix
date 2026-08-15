{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "tailscale";
    module = self.nixosModules.tailscale;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.tailscale.enable;
            message = "tailscale should be enabled";
          }
          {
            assertion = builtins.elem "tailscale0" config.networking.firewall.trustedInterfaces;
            message = "tailscale0 should be trusted";
          }
          {
            assertion = config.networking.firewall.checkReversePath == "loose";
            message = "reverse path filtering should be loose";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat tailscaled.service")
    '';
  }
