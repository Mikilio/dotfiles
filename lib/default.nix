{
  inputs,
  lib,
}: let
  inherit (builtins) pathExists readDir readFileType;
  inherit (lib) attrNames concatMapAttrs filterAttrs functionArgs hasAttr isFunction mapAttrs removeAttrs setFunctionArgs;
  inherit (lib.strings) hasSuffix removeSuffix;

  readModules = dir:
    if pathExists "${dir}.nix" && readFileType "${dir}.nix" == "regular"
    then {default = dir;}
    else if pathExists dir && readFileType dir == "directory"
    then
      concatMapAttrs
      (entry: type: let
        dirDefault = "${dir}/${entry}/default.nix";
      in
        if type == "regular" && hasSuffix ".nix" entry && entry != "flake-module.nix"
        then {${removeSuffix ".nix" entry} = "${dir}/${entry}";}
        else if pathExists dirDefault && readFileType dirDefault == "regular"
        then {${entry} = dirDefault;}
        else {})
      (readDir dir)
    else {};

  injectInputs = modules:
    mapAttrs
    (_: path: let
      mod = import path;
    in
      if isFunction mod
      then let
        modArgs = functionArgs mod;
        injected = filterAttrs (name: _: hasAttr name modArgs) {inherit inputs;};
        remaining = removeAttrs modArgs (attrNames injected);
        withInputs = args: mod (args // injected);
      in
        setFunctionArgs withInputs remaining
      else path)
    modules;
in {
  inherit readModules injectInputs;
}
