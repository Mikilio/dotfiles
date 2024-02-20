{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: {
    config,
    lib,
    pkgs,
    ...
  }: let
  in {
    config = {
      services.syncthing = {
        enable = true;
        extraOptions = [];
      };

      home.packages = [
        pkgs.syncthingtray
      ];
    };
  }
)
