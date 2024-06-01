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
      package = inputs.wezterm.packages.${pkgs.system}.default;
      extraConfig = builtins.readFile ./wezterm.lua;
    };
  };
}
