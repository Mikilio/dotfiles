{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "pacman";
    module = self.nixosModules.pacman;
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("command -v pacman")
      machine.succeed("test -f /etc/pacman.conf")
      machine.succeed("test -f /etc/makepkg.conf")
      machine.succeed("test -d /var/lib/pacman")
    '';
  }
