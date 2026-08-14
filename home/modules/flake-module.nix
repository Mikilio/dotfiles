{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (import ../../lib {inherit inputs lib;}) injectInputs readModules;
in {
  flake.homeModules = injectInputs (readModules "${self.sourceInfo.outPath}/home/modules");
}
