{
  description = "Mikilio's NixOS and Home-Manager flake";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} rec {
      systems = ["x86_64-linux"];

      imports = [
        inputs.ez-configs.flakeModule
        inputs.home-manager.flakeModules.home-manager
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = {
          inherit inputs ezConfigs;
        };
        home = {
          configurationsDirectory = "${ezConfigs.root}/home/profiles";
          modulesDirectory = "${ezConfigs.root}/home/modules";
        };
        nixos = {
          configurationsDirectory = "${ezConfigs.root}/nixos/hosts";
          modulesDirectory = "${ezConfigs.root}/nixos/modules";
          hosts = {
            elitebook = {
              userHomeModules = ["mikilio"];
            };
            gamebox = {
              userHomeModules = ["mikilio"];
            };
            installer.importDefault = false;
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
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.11";
    patched.url = "github:Mikilio/nixpkgs/zotero";

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

    fjordlauncher = {
      url = "github:unmojang/FjordLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.48.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprshell = {
      url = "github:Mikilio/hyprshell";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    impermanence.url = "github:nix-community/impermanence";

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    neovix = {
      url = "github:Mikilio/neovix/lz-n";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    # language-tool = {
    #   url = "https://addons.thunderbird.net/thunderbird/downloads/file/1031394/grammatik_und_rechtschreibprufung_languagetool-8.11.2-tb.xpi?src=version-history";
    #   flake = false;
    # };

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

    sessionx = {
      url = "github:omerxx/tmux-sessionx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    srvos.url = "github:nix-community/srvos";

    templates.url = "github:NixOS/templates";

    thunderAI = {
      url = "https://github.com/micz/ThunderAI/releases/download/v3.4.1/thunderai-v3.4.1.xpi";
      flake = false;
    };

    # tbConversations = {
    #   url = "https://addons.thunderbird.net/thunderbird/downloads/latest/gmail-conversation-view/addon-54035-latest.xpi?src=dp-btn-primary";
    #   flake = false;
    # };

    yazi = {
      url = "github:sxyazi/yazi";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://mikilio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mikilio.cachix.org-1:nYplhDMbu04QkMOJlCfSsEuFYFHp9VMKbChfL2nMKio="
    ];
  };
}
