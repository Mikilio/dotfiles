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
          earlyModuleArgs = {inherit inputs;};
          configurationsDirectory = "${ezConfigs.root}/home/profiles";
          modulesDirectory = "${ezConfigs.root}/home/modules";
        };
        nixos = {
          earlyModuleArgs = {inherit inputs;};
          configurationsDirectory = "${ezConfigs.root}/nixos/hosts";
          modulesDirectory = "${ezConfigs.root}/nixos/modules";
          hosts = {
            elitebook = {
              userHomeModules = ["mikilio"];
            };
            gamebox = {
              userHomeModules = ["mikilio"];
            };
            pi-probe.importDefault = false;
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

    anyrun-rbw.url = "github:uttarayan21/anyrun-rbw";

    devenv.url = "github:cachix/devenv";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fjordlauncher = {
      url = "github:unmojang/FjordLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:Mikilio/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
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
        nixpkgs.follows = "nixpkgs";
      };
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

    stylix.url = "github:nix-community/stylix";

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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.home-manager.follows = "home-manager";
    };
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
