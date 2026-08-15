{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-media";
    # The media module overrides beets with the `xtractor` plugin via
    # `python3.pkgs.beets-xtractor`, which no longer exists in the pinned
    # nixpkgs fork, so the module fails to evaluate.
    module = {};
    meta.broken = true;
    testScript =
      loginScript
      + ''
        machine.wait_for_unit("multi-user.target")
      '';
  }
