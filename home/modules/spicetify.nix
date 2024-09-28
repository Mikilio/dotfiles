{
  inputs,
  pkgs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];
  # import the flake's module for your system
  config = {
    # configure spicetify :)
    programs.spicetify = {
      enable = true;
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
