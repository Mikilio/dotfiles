{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-hyprland";
    module = self.homeModules.hyprland;
    modules = [xdgPortalSystemAccommodation];
    homeModules = [hyprlandAccommodation hyprlandPackageAccommodation];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'uwsm --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/hypr/hyprland.lua'")
      '';
  }
