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
        #get freshed eww
        inputs.eww.overlays.default
        inputs.rust-overlay.overlays.default
        #nur overlays
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

            #waiting for bump tp obs 30 for awesome WebRTC and improved vaapi
            obs-studio = prev.obs-studio.overrideAttrs ( o: rec {
              version = "30.0.2";
              src = prev.fetchFromGitHub {
                owner = "obsproject";
                repo = "obs-studio";
                rev = version;
                sha256 = "sha256-8pX1kqibrtDIaE1+/Pey1A5bu6MwFTXLrBOah4rsF+4=";
                fetchSubmodules = true;
              };
              # qrcodegen does not yet support cpp
              buildInputs = (final.lib.lists.remove prev.ffmpeg_4 o.buildInputs)
                ++ (with final; [ qrcodegen libdatachannel ffmpeg]);
              # can't build websocket support because of qrcodegen
              # should not build qsv11 because using amd and missing intel libs
              cmakeFlags = [
                "-DOBS_VERSION_OVERRIDE=${version}"
                "-Wno-dev" # kill dev warnings that are useless for packaging
                "-DENABLE_WEBSOCKET=OFF"
                "-DCEF_ROOT_DIR=../../cef"
                "-DENABLE_QSV11=OFF"
              ];
            });

            obs-studio-plugins = prev.obs-studio-plugins // {
              obs-pipewire-audio-capture = prev.obs-studio-plugins.obs-pipewire-audio-capture.overrideAttrs (o: {
                preConfigure = "";
              });
            };

            #waiting for bump from 20230712-072601-f4abf8fd
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
