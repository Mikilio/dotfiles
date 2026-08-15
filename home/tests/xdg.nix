{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript xdgPortalHmAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-xdg";
    module = self.homeModules.xdg;
    modules = [xdgPortalSystemAccommodation];
    homeModules = [xdgPortalHmAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'test -d ~/.config'")
        machine.succeed("su - alice -c 'test -d ~/.cache'")
        machine.succeed("su - alice -c 'test -d ~/.local/share'")
        machine.succeed("su - alice -c 'test -d ~/Code'")
      '';
  }
