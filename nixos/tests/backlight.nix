{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "backlight";
    module = self.nixosModules.backlight;
    modules = [
      {
        location.provider = "manual";
        location.latitude = 0.0;
        location.longitude = 0.0;
      }
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      # clight runs as a user service under graphical-session.target; only the
      # clightd system unit is available in a headless VM.
      machine.succeed("systemctl cat clightd.service")
    '';
  }
