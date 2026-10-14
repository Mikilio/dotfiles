{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript xdgPortalHmAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-git";
    module = self.homeModules.git;
    homeModules = [
      self.homeModules.xdg
      xdgPortalHmAccommodation
      # The git home module asserts a commit identity is set; the profile
      # normally provides it.
      {
        programs.git.settings.user = {
          name = "Alice";
          email = "alice@example.com";
        };
      }
    ];
    modules = [xdgPortalSystemAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'git --version'")
        machine.succeed("su - alice -c 'delta --version'")
        machine.succeed("su - alice -c 'gh --version'")
        machine.succeed("su - alice -c 'lazygit --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/git/config'")
        machine.succeed("su - alice -c 'test -d ~/Code'")
      '';
  }
