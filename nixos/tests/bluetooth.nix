{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "bluetooth";
    module = self.nixosModules.bluetooth;
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      # bluetooth.service is wanted by bluetooth.target (hardware-triggered),
      # so it stays inactive without a Bluetooth controller.
      machine.succeed("systemctl cat bluetooth.service")
    '';
  }
