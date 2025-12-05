{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
# terminals
  let
  in {
    config = {
      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./wezterm.lua;
      };
    };
  }
