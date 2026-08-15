{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-pass";
    module = self.homeModules.pass;
    homeModules = [
      # The rbw home-manager module asserts programs.rbw.settings.email is set;
      # the profile normally provides it.
      {
        programs.rbw.settings.email = "alice@example.com";
      }
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'pass --version'")
        machine.succeed("su - alice -c 'command -v rofi-pass'")
        machine.succeed("su - alice -c 'command -v pass-otp'")
      '';
  }
