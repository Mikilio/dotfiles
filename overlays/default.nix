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
  }: {
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

            greetd =
              prev.greetd
              // {
                regreet = prev.greetd.regreet.overrideAttrs (oldAttrs: rec {
                  version = "0.1.0";
                  src = prev.fetchFromGitHub {
                    owner = "rharish101";
                    repo = "ReGreet";
                    rev = version;
                    hash = "sha256-9Wae2sYiRpWYXdBKsSNKhG5RhIun/Ro9xIV4yl1/pUc=";
                  };
                  cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
                    inherit src;
                    outputHash = "sha256-J87eobuYwLnn5qIp7Djlg7sDHa1oIk/dornzGLhQ/Fo=";
                  });
                });
              };

            clightd = prev.clightd.overrideAttrs (old: {
              version = "5.9";
              src = prev.fetchFromGitHub {
                owner = "FedeDP";
                repo = "clightd";
                rev = "e273868cb728b9fd0f36944f6b789997e6d74323";
                hash = "sha256-0NYWEJNVDfp8KNyWVY8LkvKIQUTq2MGvKUGcuAcl82U=";
              };
            });

            discord-canary = prev.discord-canary.override {
              nss = prev.nss_latest;
              withOpenASAR = true;
            };

            vivaldi = prev.vivaldi.override {
              proprietaryCodecs = true;
              enableWidevine = true;
            };

            vivaldi-ffmpeg-codecs = prev.vivaldi-ffmpeg-codecs.overrideAttrs (_: rec {
              version = "111306";
              src = final.fetchurl {
                url = "https://api.snapcraft.io/api/v1/snaps/download/XXzVIXswXKHqlUATPqGCj2w2l7BxosS8_34.snap";
                sha256 = "sha256-Dna9yFgP7JeQLAeZWvSZ+eSMX2yQbX2/+mX0QC22lYY=";
              };

              buildInputs = with final; [squashfsTools];

              unpackPhase = ''
                unsquashfs -dest . $src
              '';

              installPhase = ''
                install -vD chromium-ffmpeg-${version}/chromium-ffmpeg/libffmpeg.so $out/lib/libffmpeg.so
              '';
            });
          }
        )
      ];
    };
  };
}
