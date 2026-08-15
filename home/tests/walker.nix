{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation xdgPortalSystemAccommodation;
in
  mkHomeTest {
    name = "home-walker";
    module = self.homeModules.walker;
    modules = [xdgPortalSystemAccommodation];
    homeModules = [
      self.homeModules.hyprland
      hyprlandAccommodation
      hyprlandPackageAccommodation
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'walker --version'")
        machine.succeed("su - alice -c 'test -f ~/.config/walker/config.toml'")
      '';
  }
