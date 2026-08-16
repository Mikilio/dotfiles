{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation;
in
  mkHomeTest {
    name = "home-zus";
    module = self.homeModules.zus;
    modules = [nurAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'rclone version'")
        machine.succeed("su - alice -c 'test -f ~/.config/rclone/rclone.conf'")
      '';
  }
