{ inputs' }:
{ config,
  pkgs,
  lib,
  ...
}:
with lib; let
  spicePkgs = inputs'.spicetify-nix.packages.default;
  cfg = config.preferences.apps.media;
in {
  # import the flake's module for your system
  config = mkIf cfg {
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
