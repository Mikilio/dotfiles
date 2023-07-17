{
  default,
  inputs,
  lib,
  self,
  withSystem,
  sharedModules,
  ...
}:
with lib; let
  sharedModules = [
    inputs.sops-nix.nixosModules.default
    self.nixosModules.core
    self.nixosModules.network
    self.nixosModules.nix
    self.nixosModules.security
  ];

  desktopModules = with inputs; [
    hyprland.nixosModules.default
    kmonad.nixosModules.default
    nix-gaming.nixosModules.default
  ];
in {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({
    system,
    self',
    inputs',
    ...
  }: {
    homestation = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit self inputs self' inputs' default;
      };

      modules =
        [
          ./homestation
          self.nixosModules.greetd
          self.nixosModules.desktop
          self.nixosModules.gamemode
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
        ]
        ++ sharedModules
        ++ desktopModules;
    };
  });
}
