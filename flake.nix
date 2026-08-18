{
  description = "Mikilio's NixOS and Home-Manager flake";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} rec {
      systems = ["x86_64-linux"];

      imports = [
        ./nixos/modules/flake-module.nix
        ./nixos/tests/flake-module.nix
        ./home/modules/flake-module.nix
        ./home/tests/flake-module.nix
      ];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixd
            ];
          };
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:Mikilio/nixpkgs/package/rosec";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    patched.url = "github:NixOS/nixpkgs/9be065038f6f8f10f33634af78ee4d73682f785e";

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

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dcal = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant";

    fjordlauncher = {
      url = "github:unmojang/FjordLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:Mikilio/home-manager/herdr-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    neovix = {
      url = "github:Mikilio/neovix";
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

    opencode-config = {
      url = "github:Mikilio/opencode-config";
      flake = false;
    };

    sessionx = {
      url = "github:omerxx/tmux-sessionx";
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

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

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
