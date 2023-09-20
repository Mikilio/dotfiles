{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.preferences;

  # use OCR and copy to clipboard
  ocrScript = let
    inherit (pkgs) wayshot libnotify slurp tesseract5 wl-clipboard;
    _ = lib.getExe;
  in
    pkgs.writeShellScriptBin "wl-ocr" ''
      ${_ wayshot} -g "$(${_ slurp})" -t ppm - | ${_ tesseract5} - - | ${wl-clipboard}/bin/wl-copy
      ${_ libnotify} "$(${wl-clipboard}/bin/wl-paste)"
    '';

  listOfCompositor = [
    "hyprland"
  ];

  listOfBars = [
    "waybar"
  ];

  desktopModule = types.submodule {
    options = {

      compositor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Choose your wayland compositor!
          No X11 in this config!
          I have traumatic experiences with those
        '';
      };

      statusbar = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Choose your statusbar!
        '';
      };
    };
  };
in {
  #import all common configurations
  imports = [
    inputs.anyrun.homeManagerModules.default
    (import ./anyrun.nix {inherit inputs';})
    ./swayidle.nix
    ./swaylock.nix
    ./waybar
    inputs.hyprland.homeManagerModules.default
    ./wireplumber
    ./dunst.nix
    (import ./hyprland {inherit inputs';})
  ];

  options = {
    preferences.desktop = mkOption {
      type = desktopModule;
      default = {};
      description = ''
        Desktop configuration. define your desktop envirionment!
      '';
    };
  };

  config = mkIf (!isNull cfg.desktop) {
    home.packages = with pkgs; [
      # screenshot
      wayshot
      slurp

      # idle/lock
      swaylock-effects

      # utils
      libnotify
      ocrScript
      wl-screenrec
      cliphist
      wl-clipboard
      wlogout
      wlr-randr
      hyprpicker
    ];
  };
})
