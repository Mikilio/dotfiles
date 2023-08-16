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
          ]
        );
      overlays = [
        #enable devshell
        inputs.devshell.overlays.default

        nur.repos.mikilio.overlays.thunar

        #all normal overrides
        (
          final: prev: {
            keepasscx = prev.keepassxc.override {withKeePassX11 = false;};

            steam = prev.steam.override {
              extraPkgs = pkgs:
                with pkgs; [
                  keyutils
                  libkrb5
                  libpng
                  libpulseaudio
                  libvorbis
                  stdenv.cc.cc.lib
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXinerama
                  xorg.libXScrnSaver
                ];
              extraProfile = ''
                export GDK_SCALE=2
                export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${inputs'.nix-gaming.packages.proton-ge}'
              '';
            };

            discord-canary = prev.discord-canary.override {
              nss = prev.nss_latest;
              withOpenASAR = true;
            };
            
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
