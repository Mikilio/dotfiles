{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "networking";
    module = self.nixosModules.networking;
    modules = [
      {
        dotfiles.networking.target = "desktop";
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.networking.networkmanager.enable;
            message = "NetworkManager should be enabled";
          }
          {
            assertion = config.services.resolved.enable;
            message = "systemd-resolved should be enabled";
          }
          {
            assertion = config.services.openssh.enable;
            message = "openssh should be enabled";
          }
          {
            assertion = config.networking.nftables.enable;
            message = "nftables should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("NetworkManager.service")
      machine.wait_for_unit("systemd-resolved.service")
    '';
  }
