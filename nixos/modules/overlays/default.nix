{
  inputs,
  lib,
  pkgs,
  ...
}: let
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
in {
  imports = [
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg:
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
      permittedInsecurePackages = ["electron.*"];
      allowUnsupportedSystem = true;
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
                # gamemode
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

          logseq = prev.logseq.overrideAttrs (oldAttrs: {
            postFixup = ''
              makeWrapper ${prev.electron_27}/bin/electron $out/bin/${oldAttrs.pname} \
                --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
                --add-flags $out/share/${oldAttrs.pname}/resources/app \
                --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
                --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [prev.stdenv.cc.cc.lib]}"
            '';
          });

          discord = prev.discord-canary.override {
            nss = prev.nss_latest;
            withOpenASAR = true;
            withVencord = true;
          };

          flutter = prev.flutter319;

          kicad = prev.kicad;

          pass-secret-service = prev.pass-secret-service;

          vivaldi = prev.vivaldi.override {
            proprietaryCodecs = true;
            enableWidevine = true;
          };

          # PR patched-1
          floorp = patched.floorp;

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
