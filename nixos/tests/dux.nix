{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "dux";
    module = self.nixosModules.dux;
    modules = [
      self.nixosModules.hyprland
      ({config, ...}: {
        assertions = [
          # {
          #   assertion = config.programs.dank-material-shell.enable;
          #   message = "dux-shell should be enabled";
          # }
          # {
          #   assertion = config.programs.dank-calendar.enable;
          #   message = "dank-calendar should be enabled";
          # }
          # {
          #   assertion = config.programs.dsearch.enable;
          #   message = "dsearch should be enabled";
          # }
          # {
          #   assertion = config.programs.dux-greeter.enable;
          #   message = "dux-greeter should be enabled";
          # }
          # {
          #   assertion = config.programs.dux-greeter.compositor.name == "hyprland";
          #   message = "dux-greeter should use hyprland";
          # }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
