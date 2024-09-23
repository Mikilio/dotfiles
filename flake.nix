{
  description = "Mikilio's NixOS and Home-Manager flake";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} rec {
      systems = ["x86_64-linux"];

      imports = [
        inputs.ez-configs.flakeModule
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = {inherit inputs ezConfigs;};
        home = {
          configurationsDirectory = "${ezConfigs.root}/home/profiles";
          modulesDirectory = "${ezConfigs.root}/home/modules";
        };
        nixos = {
          configurationsDirectory = "${ezConfigs.root}/nixos/hosts";
          modulesDirectory = "${ezConfigs.root}/nixos/modules";
          hosts = {
            elitebook ={
              userHomeModules = [ "mikilio" ];
            };
          };
        };
      };

      perSystem = {
        pkgs,
        lib,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;
      };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/23.11";
    patched.url = "github:Mikilio/nixpkgs/patch-1";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cloudflared = {
      url = "github:cloudflare/cloudflared/2024.3.0";
      flake = false;
    };
    cloudflare-go = {
      url = "github:cloudflare/go/34129e47042e214121b6bbff0ded4712debed18e";
      flake = false;
    };

    devenv.url = "github:cachix/devenv";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # eww = {
    #   url = "github:hylophile/eww/dynamic-icons";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.rust-overlay.follows = "rust-overlay";
    # };

    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # gBar = {
    #   url = "github:Mikilio/gBar/xdg-paths";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    helix = {
      url = "github:/helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    home-manager = {
      url = "github:brckd/home-manager/firefox/floorp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprshell = {
      url = "github:Mikilio/hyprshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    neovix = {
        url = "github:Mikilio/neovix";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.flake-parts.follows = "flake-parts";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sessionx = {
      url = "github:omerxx/tmux-sessionx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:Mikilio/stylix/regreet";

    templates.url = "github:NixOS/templates";

    # wezterm = {
    #   url = "github:wez/wezterm?dir=nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://helix.cachix.org"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://mikilio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mikilio.cachix.org-1:nYplhDMbu04QkMOJlCfSsEuFYFHp9VMKbChfL2nMKio="
    ];
  };
}
