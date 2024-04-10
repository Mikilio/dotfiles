{
  config,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
in {
  perSystem = {
    system,
    inputs',
    ...
  }:
    with inputs.nixpkgs.lib; let
      mkPkgs = import inputs.nixpkgs;
      stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      inherit (extends inputs.nur.overlay mkPkgs {inherit system;}) nur;

    in {
      _module.args.pkgs = mkPkgs {
        inherit system;
        # allow spotify to be installed if you don't have unfree enabled already
        config.allowUnfreePredicate = pkg:
          builtins.elem [] (
            map (re: builtins.match re (lib.getName pkg)) [
              "spotify"
              "steam.*"
              "languagetool*"
              "tampermonkey*"
              "wikiwand.*"
              "morgen.*"
            ]
          );
        config.permittedInsecurePackages = [
          "nix-2.16.2"
        ];

        overlays = [
          #enable devshell
          inputs.devshell.overlays.default
          #get freshed eww
          inputs.eww.overlays.default
          inputs.rust-overlay.overlays.default
          #nur overlays
          nur.repos.mikilio.overlays.thunar
          nur.repos.mikilio.overlays.waybar
          # nur.repos.mikilio.overlays.ultimateKeys

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
                extraPkgs = p: with p; [];
                extraLibraries = p:
                  with p; [
                    jansson
                    libGL
                  ];
              };
              
              #NOTE: https://github.com/obsproject/obs-studio/issues/10397
              obs-studio = stable.obs-studio;

              discord-canary = prev.discord-canary.override {
                nss = prev.nss_latest;
                withOpenASAR = true;
                withVencord = true;
              };

              morgen = prev.morgen.overrideAttrs (o: {
                installPhase = ''
                  runHook preInstall

                  mv usr $out
                  mv opt $out

                  asar extract $out/opt/Morgen/resources/app.asar "$TMP/work"
                  # 1. Fixes path for todesktop-runtime-config.json
                  # 2. Fixes startup script
                  substituteInPlace $TMP/work/dist/main.js \
                    --replace "process.resourcesPath,\"todesktop-runtime-config.json" "\"$out/opt/Morgen/resources/todesktop-runtime-config.json" \
                    --replace "Exec=\".concat(process.execPath," "Exec=\".concat(\"$out/bin/morgen\","
                  asar pack --unpack='{*.node,*.ftz,rect-overlay}' "$TMP/work" $out/opt/Morgen/resources/app.asar

                  substituteInPlace $out/share/applications/morgen.desktop \
                    --replace '/opt/Morgen' $out/bin

                  makeWrapper ${prev.electron}/bin/electron $out/bin/morgen \
                    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer}} $out/opt/Morgen/resources/app.asar"

                  runHook postInstall
                '';
              });

              vivaldi = prev.vivaldi.override {
                proprietaryCodecs = true;
                enableWidevine = true;
              };
              
              yazi = inputs'.yazi.packages.default.overrideAttrs (o: {
                patches = (o.patches or [ ]) ++ [
                  ./yazi/symlink-status.patch
                ];
              });
            }
          )
        ];
      };
    };
}
