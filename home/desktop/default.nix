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

  listOfCompositor = [
    "hyprland"
  ];

  listOfBars = [
    "waybar"
    "eww"
    "gBar"
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
  imports = builtins.map (mod: import mod {inherit inputs' inputs;}) [
    ./anyrun.nix
    ./ags
    ./waybar
    ./gbar.nix
    ./wireplumber
    ./dunst.nix
    ./hyprland
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
      wl-screenrec
      cliphist
      wl-clipboard
      wlogout
      wlr-randr
      hyprpicker
    ];
  };
})
