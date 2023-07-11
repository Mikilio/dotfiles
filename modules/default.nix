{
  self,
  inputs,
  default,
  ...
}: let
in {
  flake.nixosModules = {
    core = import ./core.nix;
    desktop = import ./desktop.nix;
    gamemode = import ./gamemode.nix;
    greetd = import ./greetd.nix;
    network = import ./network.nix;
    nix = import ./nix.nix;
    security = import ./security.nix;
  };
}
