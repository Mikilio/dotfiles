{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-ssh";
    module = self.homeModules.ssh;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'ssh -V'")
        machine.succeed("su - alice -c 'test -f ~/.ssh/config'")
        machine.succeed("su - alice -c 'command -v ssh-agent'")
      '';
  }
