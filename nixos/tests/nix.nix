{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "nix";
    module = self.nixosModules.nix;
    modules = [
      ({config, ...}: {
        assertions = [
          {
            assertion = config.programs.nh.enable;
            message = "nh should be enabled";
          }
          {
            assertion = config.nix.settings.auto-optimise-store;
            message = "auto-optimise-store should be enabled";
          }
          {
            assertion = builtins.elem "flakes" config.nix.settings.experimental-features;
            message = "flakes experimental feature should be enabled";
          }
          {
            assertion = builtins.length (builtins.attrNames config.nix.registry) > 0;
            message = "nix registry should be populated from flake inputs";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      # The daemon is socket-activated; the socket is wanted by sockets.target.
      machine.wait_for_unit("nix-daemon.socket")
      machine.succeed("nix eval --expr '1 + 1'")
      machine.succeed("nh --help >/dev/null")
    '';
  }
