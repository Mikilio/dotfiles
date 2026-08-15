{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "syncthing";
    module = self.nixosModules.syncthing;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = builtins.elem 22000 config.networking.firewall.allowedUDPPorts;
            message = "syncthing QUIC port should be open";
          }
          {
            assertion = builtins.elem 21027 config.networking.firewall.allowedUDPPorts;
            message = "syncthing discovery port should be open";
          }
          {
            assertion = builtins.elem 22000 config.networking.firewall.allowedTCPPorts;
            message = "syncthing TCP port should be open";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
