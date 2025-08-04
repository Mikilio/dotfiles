{
  inputs,
  lib,
  pkgs,
  ...
}: let
  stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv) system;
    config.allowUnfree = true;
    config.permittedInsecurePackages = ["electron-27.3.11"];
  };
  patched = import inputs.patched {
    inherit (pkgs.stdenv) system;
    config.allowUnfree = true;
  };
in {
  imports = [
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg:
        builtins.elem [] (
          map (re: builtins.match re (lib.getName pkg)) [
            # The Wall of Shame
            "spotify"
            "steam.*"
            "languagetool*"
            "tampermonkey*"
            "wikiwand.*"
            "discord.*"
            "teams"
            "slack.*"
            "zoom.*"
            "morgen"
          ]
        );
      allowUnsupportedSystem = true;
    };

    overlays = [
      inputs.sops-nix.overlays.default
      # inputs.hyprland.overlays.default
      #all normal overrides
      (final: prev: {
        lib =
          prev.lib
          // {
            mkOptional =
              # Name for the created option
              name:
                prev.lib.mkOption {
                  default = true;
                  example = true;
                  description = "Whether to enable ${name}.";
                  type = lib.types.bool;
                };
          };

        # inherit (stable) logseq;

        clight = prev.clight.overrideAttrs (o: {
          postInstall = ''
            rm -r $out/etc/xdg/autostart
          '';
        });

        steam = prev.steam.override {
          extraPkgs = pkgs:
            with pkgs; [
              keyutils
              libkrb5
              gamemode
            ];
        };

        lutris = prev.lutris.override {
          extraPkgs = p: [];
          extraLibraries = p:
            with p; [
              jansson
              libGL
            ];
        };

        # #Lot of rebuild be careful
        # rocmPackages = prev.rocmPackages.overrideScope (
        #   _final: prev: {
        #     clr = prev.clr.overrideAttrs (o: {
        #       passthru = o.passthru // {
        #         gpuTargets = [
        #           "gfx1103"
        #           "gfx1031"
        #         ];
        #       };
        #     });
        #   }
        # );

        discord = prev.discord-canary.override {
          nss = prev.nss_latest;
          withOpenASAR = true;
          withVencord = true;
        };

        ghostty = prev.ghostty.overrideAttrs (o: {
          postPatch = ''
            shopt -s globstar
            substituteInPlace **/*.zig --replace 'const xev = @import("xev");' 'const xev = @import("xev").Epoll;'
            shopt -u globstar
          '';
        });

        vivaldi = prev.vivaldi.override {
          proprietaryCodecs = true;
          enableWidevine = true;
        };

        fjordlauncher = inputs.fjordlauncher.packages.${pkgs.system}.fjordlauncher.override {
          fjordlauncher-unwrapped =
            inputs.fjordlauncher.packages.${pkgs.system}.fjordlauncher-unwrapped.overrideAttrs
            (o: {
              patches =
                (o.patches or [])
                ++ [
                  ./fjord/no_drm.patch
                ];
            });
        };

        python3 = prev.python3.override {
          packageOverrides = python-self: python-super: {
            pypass = python-super.pypass.overrideAttrs (o: {
              patches =
                (o.patches or [])
                ++ [
                  ./pypass/multi-gpgid.patch
                ];
            });
          };
        };

        yazi = inputs.yazi.packages.${pkgs.stdenv.system}.default.overrideAttrs (o: {
          patches =
            (o.patches or [])
            ++ [
              ./yazi/symlink-status.patch
            ];
        });

        zen-browser = inputs.zen-browser.packages.${pkgs.system}.default;

        # Zoom, again.
        # https://qumulo.zoom.us
        zoom-us = prev.zoom-us.overrideAttrs {
          version = "6.2.10.4983";
          src = pkgs.fetchurl {
            url = "https://zoom.us/client/6.2.10.4983/zoom_x86_64.pkg.tar.xz";
            hash = "sha256-lPUKxkXI3yB/fCY05kQSJhTGSsU6v+t8nq5H6FLwhrk=";
          };
        };
      })
    ];
  };
}
