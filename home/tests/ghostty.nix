{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-ghostty";
    module = self.homeModules.ghostty;
    homeModules = [
      self.homeModules.herdr
      {
        programs.herdr.enable = true;
        # No facter report in this test, and the server is not what is under
        # test here — only that ghostty runs the module's attach command.
        programs.herdr.memoryMax = "1G";
      }
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'ghostty --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/ghostty/config'")
        machine.succeed("su - alice -c 'grep -q herdr-attach ~/.config/ghostty/config'")
      '';
  }
