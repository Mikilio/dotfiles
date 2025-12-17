{
  inputs,
  lib,
  pkgs,
  ...
}: let
  stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
  patched = import inputs.patched {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  noGPU = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      rocmSupport = lib.mkForce false;
      cudaSupport = lib.mkForce false;
    };
  };
in {
  imports = [
  ];

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        #user spoofing
        "jitsi-meet-1.0.8792"
      ];
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
            "obsidian"
            "zerotierone"
            "teamviewer.*"
            "libfprint-2-tod1-goodix"
          ]
        );
      allowUnsupportedSystem = true;
    };

    overlays = [
      inputs.sops-nix.overlays.default
      inputs.nur.overlays.default
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

        inherit (stable) zerotierone;
        inherit (noGPU) thunderbird;

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

        fjordlauncher = let
          inherit (pkgs.stdenv.hostPlatform) system;
        in
          inputs.fjordlauncher.packages.${system}.fjordlauncher.override {
            fjordlauncher-unwrapped =
              inputs.fjordlauncher.packages.${system}.fjordlauncher-unwrapped.overrideAttrs
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

        zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
