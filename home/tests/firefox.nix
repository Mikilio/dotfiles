{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript nurAccommodation;
in
  mkHomeTest {
    name = "home-firefox";
    # The firefox module references the NUR addon `omnivore`
    # (`pkgs.nur.repos.rycee.firefox-addons`), which no longer exists in the
    # pinned NUR, so the module fails to evaluate.
    module = {};
    modules = [nurAccommodation];
    meta.broken = true;
    testScript =
      loginScript
      + ''
        machine.wait_for_unit("multi-user.target")
      '';
  }
