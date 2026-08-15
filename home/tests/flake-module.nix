{
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: {
    checks = import ./default.nix {inherit inputs lib pkgs self;};
  };
}
