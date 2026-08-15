{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
  system = pkgs.stdenv.hostPlatform.system;
  stableDavfs2 = (import inputs.nixpkgs-stable {inherit system;}).davfs2;
in
  mkTest {
    name = "overlays";
    module = self.nixosModules.overlays;
    modules = [
      ({
        config,
        pkgs,
        ...
      }: {
        assertions = [
          {
            assertion = pkgs.davfs2.version == stableDavfs2.version;
            message = "davfs2 overlay should come from nixpkgs-stable";
          }
          {
            assertion = builtins.elem "electron-40.10.5" config.nixpkgs.config.permittedInsecurePackages;
            message = "electron should be permitted as insecure";
          }
          {
            assertion = config.nixpkgs.config.allowUnsupportedSystem;
            message = "allowUnsupportedSystem should be enabled";
          }
          {
            assertion = pkgs ? discord;
            message = "discord should be overridden";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
