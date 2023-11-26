{ config
, inputs
, ...
}:

let
  inherit (inputs.nixpkgs) lib;
in {
  perSystem = {
    system,
    inputs',
    ...
  }: 
  
  with inputs.nixpkgs.lib;

  let
    
    mkPkgs = import inputs.nixpkgs;
    inherit (extends inputs.nur.overlay mkPkgs { inherit system; }) nur;
    
  in {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # allow spotify to be installed if you don't have unfree enabled already
      config.allowUnfreePredicate = pkg:
        builtins.elem [] (
          map (re: builtins.match re (lib.getName pkg)) [
            "spotify"
            "obsidian"
            "vivaldi*"
            "widevine-cdm"
            "steam.*"
            "discord-canary"
            "waveform"
            ".*amd.*"
          ]
        );
      overlays = [
        #enable devshell
        inputs.devshell.overlays.default

        nur.repos.mikilio.overlays.thunar
        nur.repos.mikilio.overlays.waybar

        #all normal overrides
        (
          final: prev: {
            keepasscx = prev.keepassxc.override {withKeePassX11 = false;};

            steam = prev.steam.override {
              extraPkgs = pkgs:
                with pkgs; [
                  keyutils
                  libkrb5
                ];
              extraProfile = ''
                export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${inputs'.nix-gaming.packages.proton-ge}'
              '';
            };

            lutris = prev.lutris.override {
              extraPkgs = p: with p;[ ];
              extraLibraries = p: with p;[
                jansson
                libGL
              ];
            };

            discord-canary = prev.discord-canary.override {
              nss = prev.nss_latest;
              withOpenASAR = true;
              withVencord = true;
            };

            # temp rollback until https://github.com/rharish101/ReGreet/issues/32 is solved
            greetd = prev.greetd // {
              regreet = prev.greetd.regreet.overrideAttrs (self: super: rec {
                version = "0.1.1-patched";
                src = prev.fetchFromGitHub {
                  owner = "rharish101";
                  repo = "ReGreet";
                  rev = "ccffff87f621d9ea0d3c0f6ca64b361509d1dbc3";
                  hash = "sha256-6VdM7W8Sx+D6Lp8LijuWWvGhRS+QIW4CWn1OATGqBPc=";
                };
                cargoDeps = super.cargoDeps.overrideAttrs (_: {
                  inherit src;
                  outputHash = "sha256-M1ha8tL5j5B1wOOrBRQ7qEDbsaSzfrluqT35W9RWluI=";
                });
              });
            };

            wezterm = prev.callPackage ./wezterm {}; 
          
            vivaldi = prev.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
            };
          }
        )
      ];
    };
  };
}
