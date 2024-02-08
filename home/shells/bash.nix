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
    programs = {
      bash = {
        enable = true;
      };
    };
  };
})
