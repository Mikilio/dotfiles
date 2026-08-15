{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-vivaldi";
    module = {};
    meta.broken = true;
    testScript =
      loginScript
      + ''
        machine.wait_for_unit("multi-user.target")
      '';
  }
