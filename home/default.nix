{
  inputs,
  self,
  lib,
  config,
  ...
}:
with lib;
  inputs.flake-parts.lib.mkTransposedPerSystemModule {
    name = "homeManagerModules";
    option = mkOption {
      type = types.lazyAttrsOf types.unspecified;
      default = {};
      apply = mapAttrs (k: v: {
        _file = "${toString self.outPath}/flake.nix#homeManagerModules.${k}";
        imports = [v];
      });
      description = ''
        A module for home-manager configurations.

        You may use this for reusable pieces of configuration, service modules,
        etc.
      '';
    };
    file = ./default.nix;
  }
  // {
    imports = [
      ./profiles
      ./applications
      ./shells
      ./desktop
      ./bootstrap.nix
    ];
  }
