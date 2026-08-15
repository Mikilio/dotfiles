{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "distro-testing";
    module = self.nixosModules.distro-testing;
    modules = [
      {
        specialisation.ubuntu.configuration = {};
        specialisation.arch.configuration = {};
      }
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("systemctl cat systemd-nspawn@ubuntu.service")
    '';
  }
