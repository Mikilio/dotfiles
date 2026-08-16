{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-gpg";
    module = self.homeModules.gpg;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'gpg --version'")
        machine.succeed("su - alice -c 'command -v ykman'")
        machine.succeed("su - alice -c 'command -v age-plugin-yubikey'")
        machine.wait_for_unit("gpg-agent.socket", "alice")
      '';
  }
