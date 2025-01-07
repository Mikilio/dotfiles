{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  latest = import inputs.nixpkgs {
    inherit (pkgs.stdenv) system;
  };
  stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv) system;
    config.allowUnfree = true;
  };
  patched = import inputs.patched {
    inherit (pkgs.stdenv) system;
    config.allowUnfree = true;
  };
in
{
  imports =
    [
    ];

  nixpkgs = {
    config = {
      allowUnfreePredicate =
        pkg:
        builtins.elem [ ] (
          map (re: builtins.match re (lib.getName pkg)) [
            "spotify"
            "steam.*"
            "languagetool*"
            "tampermonkey*"
            "wikiwand.*"
            "discord.*"
            "teams"
            "slack.*"
            "zoom.*"
          ]
        );
      permittedInsecurePackages = [ "electron-27.3.11" ];
      allowUnsupportedSystem = true;
    };

    overlays = [
      inputs.sops-nix.overlays.default
      inputs.hyprland.overlays.default
      inputs.hyprpolkitagent.overlays.default

      #all normal overrides
      (final: prev: {

        lib = prev.lib // {
          mkOptional = # Name for the created option
            name:
            prev.lib.mkOption {
              default = true;
              example = true;
              description = "Whether to enable ${name}.";
              type = lib.types.bool;
            };
        };

        #inherit (stable) anything;

        clight = prev.clight.overrideAttrs (o: {
          postInstall = ''
            rm -r $out/etc/xdg/autostart
          '';
        });

        steam = prev.steam.override {
          extraPkgs =
            pkgs: with pkgs; [
              keyutils
              libkrb5
              # gamemode
            ];
        };

        lutris = prev.lutris.override {
          extraPkgs = p: [ ];
          extraLibraries =
            p: with p; [
              jansson
              libGL
            ];
        };

        discord = prev.discord-canary.override {
          nss = prev.nss_latest;
          withOpenASAR = true;
          withVencord = true;
        };

        vivaldi = prev.vivaldi.override {
          proprietaryCodecs = true;
          enableWidevine = true;
        };

        fjordlauncher = inputs.fjordlauncher.packages.${pkgs.system}.fjordlauncher.override {
          fjordlauncher-unwrapped =
            inputs.fjordlauncher.packages.${pkgs.system}.fjordlauncher-unwrapped.overrideAttrs
              (o: {
                patches = (o.patches or [ ]) ++ [
                  ./fjord/no_drm.patch
                ];
              });
        };

        yazi = inputs.yazi.packages.${pkgs.stdenv.system}.default.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [
            ./yazi/symlink-status.patch
          ];
        });
      })
    ];
  };
}
