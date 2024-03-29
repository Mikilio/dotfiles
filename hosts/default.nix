{
  theme,
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
    self.nixosModules.nix
    self.nixosModules.security
  ];

  desktopModules = with inputs; [
    self.nixosModules.network
    hyprland.nixosModules.default
    kmonad.nixosModules.default
    nix-gaming.nixosModules.pipewireLowLatency
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
        inherit self inputs self' inputs' theme;
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
          inputs.nur.nixosModules.nur
        ]
        ++ sharedModules
        ++ desktopModules;
    };
    homeserver = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit self inputs self' inputs';
      };

      modules =
        [
          ./homeserver
          inputs.disko.nixosModules.disko
          inputs.nixos-hardware.nixosModules.common-pc
          # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nur.nixosModules.nur
        ]
        ++ sharedModules;
    };
  });
}
