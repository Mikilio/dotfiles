{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-cli";
    module = self.homeModules.cli;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'bat --version'")
        machine.succeed("su - alice -c 'eza --version'")
        machine.succeed("su - alice -c 'fd --version'")
        machine.succeed("su - alice -c 'starship --version'")
        machine.succeed("su - alice -c 'nu --version'")
        machine.succeed("su - alice -c 'atuin --version'")
        machine.succeed("su - alice -c 'direnv --version'")
        machine.succeed("su - alice -c 'zoxide --version'")
        machine.succeed("su - alice -c 'alejandra --version'")
        machine.wait_for_unit("atuin-daemon.service", "alice")
      '';
  }
