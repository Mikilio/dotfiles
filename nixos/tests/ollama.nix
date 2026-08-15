{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "ollama";
    module = self.nixosModules.ollama;
    modules = [
      # Don't download models inside the test VM; the module wiring is what
      # we are verifying here.
      {
        services.ollama.loadModels = lib.mkForce [];
        services.ollama.syncModels = lib.mkForce false;
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.services.ollama.enable;
            message = "ollama should be enabled";
          }
          {
            assertion = config.services.ollama.rocmOverrideGfx == "10.3.0";
            message = "rocm override should be configured";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("ollama.service")
    '';
  }
