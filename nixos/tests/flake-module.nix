{
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = import ./default.nix {inherit inputs lib pkgs self;};
  };
}
