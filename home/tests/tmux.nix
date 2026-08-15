{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-tmux";
    module = self.homeModules.tmux;
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'tmux -V'")
        machine.succeed("su - alice -c 'test -f ~/.config/tmux/tmux.conf'")
      '';
  }
