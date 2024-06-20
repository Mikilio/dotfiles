{
  inputs,
  pkgs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.stdenv.system}.default;
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
      windowManagerPatch = true;

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
        trashbin
        keyboardShortcut
      ];
    };
  };
}
