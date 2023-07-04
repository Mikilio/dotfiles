{ inputs, default, ... } :

let

  eww_module = inputs.fufexan.homeManagerModules.eww-hyprland;
  hyprland_module = inputs.hyprland.homeManagerModules.default;
  anyrun_module = inputs.anyrun.homeManagerModules.default;

in {
  perSystem = { config, pkgs, lib, self', inputs', ... }@fp:
    let
      # use OCR and copy to clipboard
      ocrScript = let
        inherit (pkgs) grim libnotify slurp tesseract5 wl-clipboard;
        _ = lib.getExe;
      in
        pkgs.writeShellScriptBin "wl-ocr" ''
          ${_ grim} -g "$(${_ slurp})" -t ppm - | ${_ tesseract5} - - | ${wl-clipboard}/bin/wl-copy
          ${_ libnotify} "$(${wl-clipboard}/bin/wl-paste)"
        '';

      module = { config, lib, pkgs, ... }@hm:

      with lib;

      let
        cfg = config.home;

        listOfDesktops = [
          "sway"
          "hyprland"
        ];

      in {
        #import all common configurations
        imports = [
          anyrun_module
          ./anyrun.nix
          ./swaybg.nix
          ./swayidle.nix
          ./swaylock.nix
          eww_module
          hyprland_module
          ./hyprland
          ./sway.nix
        ];

        options = {
          home.desktop = mkOption {
            type = types.str;
            default = "hyprland";
            description = ''
              Choose your desktop environment!
            '';
          };
        };

        config = {
          home.packages = with pkgs; [
            # screenshot
            grim
            slurp

            # idle/lock
            swaybg
            swaylock-effects

            # utils
            libnotify
            ocrScript
            wf-recorder
            wl-clipboard
            wlogout
            wlr-randr
          ];

          # make stuff work on wayland
          home.sessionVariables = {
            QT_QPA_PLATFORM = "wayland";
            SDL_VIDEODRIVER = "wayland";
            XDG_SESSION_TYPE = "wayland";
        };
      };
  };

  in {
    homeManagerModules.desktop = module;
  };
}

