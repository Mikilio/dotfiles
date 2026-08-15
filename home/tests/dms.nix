{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-dms";
    module = self.homeModules.dms;
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
        machine.succeed("su - alice -c 'test -f ~/.config/hypr/hyprland.conf'")
      '';
  }
