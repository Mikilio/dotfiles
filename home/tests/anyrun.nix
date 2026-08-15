{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-anyrun";
    module = self.homeModules.anyrun;
    modules = [xdgPortalSystemAccommodation];
    homeModules = [
      self.homeModules.hyprland
      hyprlandAccommodation
      hyprlandPackageAccommodation
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'anyrun --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/anyrun/config.ron'")
      '';
  }
