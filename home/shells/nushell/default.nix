{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
hm@{
  config,
  lib,
  pkgs,
  ...
}:

with lib; let

in {
  config = {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
})
