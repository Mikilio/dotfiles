{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-dux";
    module = self.homeModules.dux;
    modules = [xdgPortalSystemAccommodation];
    homeModules = [
      self.homeModules.hyprland
      self.homeModules.ghostty
      hyprlandAccommodation
      hyprlandPackageAccommodation
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'test -f ~/.config/hypr/hyprland.lua'")

        with subtest("ghostty config references dankcolors but does not ship the theme"):
            machine.succeed("su - alice -c 'grep -q \"theme = dankcolors\" ~/.config/ghostty/config'")
            machine.fail("su - alice -c 'test -e ~/.config/ghostty/themes/dankcolors'")

        with subtest("home-manager activation tolerates the missing theme"):
            machine.succeed("systemctl is-active home-manager-alice.service")
      '';
  }
