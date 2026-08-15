{
  inputs,
  lib,
  pkgs,
  self,
}: let
  context = {inherit inputs lib pkgs self;};

  isTestFile = name: type:
    type
    == "regular"
    && lib.hasSuffix ".nix" name
    && !(lib.elem name ["default.nix" "lib.nix" "flake-module.nix"]);

  testFiles = lib.filterAttrs isTestFile (builtins.readDir ./.);

  # `nix flake check` only accepts derivations directly under checks.<system>
  # (no nesting), so the area is a flat name prefix instead of a nested set.
  importTest = name: import (./. + "/${name}") context;

  # `nix flake check` refuses to evaluate derivations with meta.broken, so
  # broken-marked tests are excluded from the checks set entirely instead of
  # being skipped at build time.
  isBroken = test: (test.meta or {}).broken or false;
in
  lib.mapAttrs'
  (name: _: {
    name = "nixos-${lib.removeSuffix ".nix" name}";
    value = importTest name;
  })
  (lib.filterAttrs (name: _: !isBroken (importTest name)) testFiles)
