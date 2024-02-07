{
  self,
  inputs,
  theme,
  withSystem,
  ...
} @ top: let

  localModules = self.homeManagerModules;

  sharedModule = hm: {
    imports = [
      inputs.nur.hmModules.nur
      inputs.nix-index-db.hmModules.nix-index
      inputs.sops-nix.homeManagerModule
    ];

    config = {
      programs.nix-index-database.comma.enable = true;

      # let HM manage itself when in standalone mode
      programs.home-manager.enable = true;

      home.stateVersion = "23.05";
    };
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in {
  flake = {
    homeConfigurations = withSystem "x86_64-linux" ({
      pkgs,
      inputs',
      ...
    }: let
      extraSpecialArgs = {
        inherit theme localModules;
      };
    in {
      full = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./full.nix
          sharedModule
        ];
      };

      minimal = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          sharedModule
        ];
      };
    });
  };
}
