{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-ai";
    # The ai module references `pkgs.herdr-nvim`, which does not exist in the
    # pinned nixpkgs fork (only `herdr` does), so it fails to evaluate.
    module = {};
    meta.broken = true;
    testScript =
      loginScript
      + ''
        machine.wait_for_unit("multi-user.target")
      '';
  }
