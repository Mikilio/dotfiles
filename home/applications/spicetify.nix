{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs', ...}: {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      spicePkgs = inputs'.spicetify-nix.packages.default;
    in {
      imports = [
        inputs.spicetify-nix.homeManagerModule
      ];
      # import the flake's module for your system
      config = {
        # configure spicetify :)
        programs.spicetify = {
          enable = true;
          theme = spicePkgs.themes.catppuccin;
          colorScheme = "mocha";

          enabledExtensions = with spicePkgs.extensions; [
            fullAppDisplay
            shuffle # shuffle+ (special characters are sanitized out of ext names)
            hidePodcasts
          ];
        };
      };
    }
)
