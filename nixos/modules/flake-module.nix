{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (import ../../lib {inherit inputs lib;}) injectInputs readModules;
in {
  flake.nixosModules = injectInputs (readModules "${self.sourceInfo.outPath}/nixos/modules");
}
