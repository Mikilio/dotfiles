{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let

  listOfBrowsers = [
    "vivaldi"
    "brave"
  ];

  listOfTerminals = [
    "alacritty"
    "foot"
    "kitty"
    "wezterm"
  ];

  listOfReaders = [
    "zathura"
    "sioyek"
  ];

  listOfMisc = [
  ];

  appsModule = types.submodule {
    options = {

      media = mkOption {
        type = types.bool;
        default = false;
        description = ''
          this enables all media related things including themed spotify.
          it also includes any form of soundcontrol.
          for more information see media.nix.
        '';
      };

      gui = mkOption {
        type = types.bool;
        default = false;
        description = ''
          this option enables all things related to gui. this includes qt
          and gtk options.
        '';
      };

      games = mkOption {
        type = types.bool;
        default = false;
        description = ''
          this option enables all gaming related things.
        '';
      };

      browser = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          this option is to choose which browser to use.
        '';
      };

      terminal = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          This option is to choose which terminal to use.
        '';
      };

      reader = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          this option is to choose which pdf-reader to use. please add
          them first to listofreaders.
        '';
      };

      productivity = mkOption {
        type = types.bool;
        default = false;
        description = ''
          this enables a set of productivity tools like obsidian and
          onlyoffice.
        '';
      };

      passwords = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Setup KeepassXC
        '';
      };

      sync = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Setup syncthing
        '';
      };

      misc = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          this option adds additional apps. please add the first to
          listofapps.
        '';
      };
    };
  };
in {
  #import all common configurations
  imports = [
    inputs.spicetify-nix.homeManagerModule
    (import ./spicetify.nix {inherit inputs';})
    ./media.nix
    ./qt.nix
    ./xdg.nix
    ./sioyek.nix
    ./vivaldi.nix
    ./gpg.nix
    (import ./games.nix {inherit inputs';})
    ./gtk.nix
    ./brave.nix
    ./zathura.nix
    ./alacritty.nix
    ./foot.nix
    ./kitty.nix
    ./wezterm.nix
    ./productivity.nix
    ./keepassxc.nix
    ./syncthing.nix
  ];

  options = {
    preferences.apps = mkOption {
      type = appsModule;
      default = {};
      description = ''
        Applications configuration. Here all graphical application related configurations will
        be placed
      '';
    };
  };
})
