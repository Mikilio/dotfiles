{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nh = {
    enable = true;
    flake = "/home/mikilio/Code/Public/github.com/Mikilio/dotfiles";
    # weekly cleanup
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 10 --keep-since 30d";
    };
  };

  # we need git for flakes
  environment.systemPackages = [pkgs.git];

  nix = {
    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # substituters
    settings = {
      sandbox = config.security.allowUserNamespaces;
      substituters = [
        # high priority since it's almost always used
        "https://cache.nixos.org?priority=10"
        "https://anyrun.cachix.org"
        "https://mikilio.cachix.org"
        "https://helix.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://yazi.cachix.org"
        # "https://unmojang.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # "unmojang.cachix.org-1:OfHnbBNduZ6Smx9oNbLFbYyvOWSoxb2uPcnXPj4EDQY="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "mikilio.cachix.org-1:nYplhDMbu04QkMOJlCfSsEuFYFHp9VMKbChfL2nMKio="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
    };
  };
}
