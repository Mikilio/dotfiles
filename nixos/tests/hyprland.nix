{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "hyprland";
    module = self.nixosModules.hyprland;
    modules = [
      inputs.dank-greeter.nixosModules.default
      ({config, ...}: {
        assertions = [
          {
            assertion = config.programs.hyprland.enable;
            message = "hyprland should be enabled";
          }
          {
            assertion = config.programs.hyprland.withUWSM;
            message = "hyprland should use UWSM";
          }
          {
            assertion = config.services.displayManager.dms-greeter.compositor.name == "hyprland";
            message = "display manager greeter should use hyprland";
          }
          {
            assertion = config.security.pam.services ? hyprlock;
            message = "hyprlock pam service should be configured";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("command -v hyprland")
    '';
  }
