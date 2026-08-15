{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "desktop-essentials";
    module = self.nixosModules.desktop-essentials;
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat udisks2.service")
      machine.succeed("systemctl cat cups.service")
      machine.succeed("systemctl cat fwupd.service")
      machine.succeed("systemctl cat pcscd.service")
    '';
  }
