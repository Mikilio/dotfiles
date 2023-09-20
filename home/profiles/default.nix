{
  self,
  inputs,
  theme,
  withSystem,
  ...
} @ top: let

  flakePath = self.outPath;

  sharedModule = hm: {
    imports = [
      self.homeManagerModules.preferences
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
      self',
      inputs',
      ...
    }: let
      extraSpecialArgs = {
        inherit flakePath theme;
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
