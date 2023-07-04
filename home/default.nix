<<<<<<< HEAD
 {
  home = {
    username = "mikilio";
    homeDirectory = "/home/mikilio";
    stateVersion = "23.05";
    extraOutputsToInstall = ["doc" "devdoc"];
  };
||||||| parent of 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
{
  home = {
    username = "mikilio";
    homeDirectory = "/home/mikilio";
    stateVersion = "23.05";
    extraOutputsToInstall = ["doc" "devdoc"];
  };
=======
{ inputs, self, lib, config, ... }:
>>>>>>> 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)

with lib;

  inputs.flake-parts.lib.mkTransposedPerSystemModule {
    name = "homeManagerModules";
    option = mkOption {
      type = types.lazyAttrsOf types.unspecified;
      default = { };
      apply = mapAttrs (k: v: { _file = "${toString self.outPath}/flake.nix#homeManagerModules.${k}"; imports = [ v ]; });
      description = ''
        A module for home-manager configurations.

        You may use this for reusable pieces of configuration, service modules,
        etc.
      '';
    };
    file = ./default.nix;
} // {

  imports = [
    ./profiles
    ./applications
    ./shells
    ./wayland
    ./bootstrap.nix
  ];
}
