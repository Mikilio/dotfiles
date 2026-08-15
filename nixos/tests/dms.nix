{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "dms";
    module = self.nixosModules.dms;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.programs.dms-shell.enable;
            message = "dms-shell should be enabled";
          }
          {
            assertion = config.programs.dank-calendar.enable;
            message = "dank-calendar should be enabled";
          }
          {
            assertion = config.programs.dsearch.enable;
            message = "dsearch should be enabled";
          }
          {
            assertion = config.programs.dms-greeter.enable;
            message = "dms-greeter should be enabled";
          }
          {
            assertion = config.programs.dms-greeter.compositor.name == "hyprland";
            message = "dms-greeter should use hyprland";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
