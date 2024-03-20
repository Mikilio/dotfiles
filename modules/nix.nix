{
  config,
  pkgs,
  self',
  inputs,
  inputs',
  lib,
  ...
}: {
  # we need git for flakes
  environment.systemPackages = [pkgs.git inputs'.devenv.packages.default];

  # pickup pkgs from flake export
  nixpkgs.pkgs = self'.legacyPackages;

  nix = {
    distributedBuilds = true;

    # auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      substituters = [
        "https://helix.cachix.org"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://mikilio.cachix.org"
      ];
      trusted-public-keys = [
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mikilio.cachix.org-1:nYplhDMbu04QkMOJlCfSsEuFYFHp9VMKbChfL2nMKio="
      ];

      trusted-users = ["root" "@wheel"];
    };
  };
}
