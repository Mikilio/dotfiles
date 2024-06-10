{
  inputs,
  lib,
  pkgs,
  ...
}:
let

      latest =  import inputs.nixpkgs {
        inherit (pkgs.stdenv) system;
      };
      stable = import inputs.nixpkgs-stable {
        inherit (pkgs.stdenv) system;
        config.allowUnfree = true;
      };
in {

  imports = [
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate =  pkg:
        builtins.elem [] (
          map (re: builtins.match re (lib.getName pkg)) [
            "spotify"
            "steam.*"
            "languagetool*"
            "tampermonkey*"
            "wikiwand.*"
            "discord.*"
            "teams"
          ]
        );
      permittedInsecurePackages = [];
      allowUnsupportedSystem  = true;

    };

    overlays = [
      inputs.rust-overlay.overlays.default
      inputs.sops-nix.overlays.default
      inputs.hyprlock.overlays.default

      #nur overlays
      #WARNING:my nur is broken
      # nur.repos.mikilio.overlays.thunar
      # nur.repos.mikilio.overlays.waybar

      #all normal overrides
      (
        final: prev: {
          keepasscx = prev.keepassxc.override {withKeePassX11 = false;};

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

          flutter = prev.flutter319;

          vivaldi = prev.vivaldi.override {
            proprietaryCodecs = true;
            enableWidevine = true;
          };

          xdg-desktop-portal-hyprland = stable.xdg-desktop-portal-hyprland;

          yazi = inputs.yazi.packages.${pkgs.stdenv.system}.default.overrideAttrs (o: {
            patches =
              (o.patches or [])
              ++ [
                ./yazi/symlink-status.patch
              ];
          });
        }
      )
    ];
  };
 }
