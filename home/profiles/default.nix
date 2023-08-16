{
  self,
  inputs,
  default,
  withSystem,
  ...
} @ top: let
  #External homeManagerModules are almost never present in perSystem
  #scoped inputs' so I can't acces them in my homeConfigurations
  #so until these are fixed I'm just adding them here.
  # TODO: create lib function that exports all inputs into simple attributes
  buggedModules = {
    spicetify-nix_module = inputs.spicetify-nix.homeManagerModule;
    nur_module = inputs.nur.hmModules.nur;
    nix-index-db_module = inputs.nix-index-db.hmModules.nix-index;
  };

  flakePath = self.outPath;

  sharedModules = withSystem "x86_64-linux" (
    {
      inputs',
      self',
      ...
    }: {
      imports = [
        self'.homeManagerModules.shells
        buggedModules.nur_module
        buggedModules.nix-index-db_module
        inputs.sops-nix.homeManagerModule
      ];

      config = {
        programs.nix-index-database.comma.enable = true;

        # let HM manage itself when in standalone mode
        programs.home-manager.enable = true;

        home.stateVersion = "23.05";
      };
    }
  );

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
        inherit inputs' self' default flakePath;
        inherit (buggedModules) spicetify-nix_module eww_module;
      };
    in {
      full = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          self'.homeManagerModules.applications
          self'.homeManagerModules.desktop
          ./full.nix
          sharedModules
        ];
      };

      minimal = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          sharedModules
        ];
      };
    });
  };
}
