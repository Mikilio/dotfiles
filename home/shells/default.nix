{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
hm@{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cliModule = types.submodule {
    options = {

      shell = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Choose your shell (By default nixos always includes bash)
        '';
      };

      starship = mkOption {
        type = types.bool;
        default = false;
        description = ''
          This enables starship as configured by ./home/shells/starship.nix
        '';
      };

      joshuto = mkOption {
        type = types.bool;
        default = false;
        description = ''
          This enables a terminal file manager called joshuto
        '';
      };

      editor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Choose your editor
        '';
      };
    };
  };

in {
  #import all common configurations
  imports = [
    ./zsh.nix
    ./starship.nix
    ./nushell
    ./joshuto
    ./git.nix
    ./nix.nix
    ./cli.nix
    (import ./helix {inherit inputs';})
    ./nvim
    ./ssh
  ];

  options = {
    preferences.cli = mkOption {
      type = cliModule;
      default = {};
      description = ''
        Shell configuration. Here all shell related configurations will
        be placed
      '';
    };
  };
})
