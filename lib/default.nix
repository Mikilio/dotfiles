{
  inputs,
  withSystem,
  ...
}:
# personal lib
let
  inherit (inputs.nixpkgs) lib;

  colorlib = import ./colors.nix lib;
  default = import ./theme {inherit colorlib lib;};
in {
  imports = [
    {
      _module.args = {
        inherit default;
      };
    }
  ];

  perSystem = {system, pkgs, packageList, ...}: {
    _module.args.pkgs= import inputs.nixpkgs {
      inherit system;
      # allow spotify to be installed if you don't have unfree enabled already
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "spotify"
      "vivaldi"
      ];
      overlays = [
        #enable devshell
        inputs.devshell.overlays.default

        #import this flakes packages into global pkgs
        # TODO : this is kinda bad find alternative
        (
          with builtins;
          final: prev: (
            listToAttrs (
              map (p: {
                name = baseNameOf p;
                value = prev.callPackage p {};
                }
              ) packageList
            )
          )
        )

        #all normal overrides
        (
          _: prev: {
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
              extraProfile = "export GDK_SCALE=2";
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
          }
        )
      ];
    };
  };
}
