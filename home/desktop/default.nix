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
  imports = [
    inputs.anyrun.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default
    inputs.gBar.homeManagerModules.x86_64-linux.default
    (import ./anyrun.nix {inherit inputs';})
    ./swayidle.nix
    ./swaylock.nix
    ./waybar
    ./gbar.nix
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
      wl-screenrec
      cliphist
      wl-clipboard
      wlogout
      wlr-randr
      hyprpicker
    ];
  };
})
