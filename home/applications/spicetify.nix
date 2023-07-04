{ config, pkgs, lib, inputs', spicetify-nix_module, ... }:

with lib;

let
  spicePkgs = inputs'.spicetify-nix.packages.default;
  cfg = config.home.applications;
in
{
  # import the flake's module for your system
  imports = [ spicetify-nix_module ];

  config = mkIf (cfg!=null && cfg.media){
    # configure spicetify :)
    programs.spicetify =
      {
        enable = true;
        theme = spicePkgs.themes.catppuccin-mocha;
        colorScheme = "flamingo";

        enabledExtensions = with spicePkgs.extensions; [
          fullAppDisplay
          shuffle # shuffle+ (special characters are sanitized out of ext names)
          hidePodcasts
        ];
      };
  };
}
