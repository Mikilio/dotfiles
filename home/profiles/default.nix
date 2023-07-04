{
  self,
  inputs,
  default,
  withSystem,
<<<<<<< HEAD
  module_args,
  default,
||||||| parent of 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
  module_args,
=======
>>>>>>> 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
  ...
<<<<<<< HEAD
}: let
  sharedModules = withSystem "x86_64-linux" ({
    inputs',
    self',
    ...
  }: [
    ../.
    ../shell
    {_module.args = {inherit inputs' self' default;};}
  ]);
||||||| parent of 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
}: let
  sharedModules = withSystem "x86_64-linux" ({
    inputs',
    self',
    ...
  }: [
    ../.
    ../shell
    module_args
    {_module.args = {inherit inputs' self';};}
  ]);
=======
}@top: let
    #External homeManagerModules are almost never present in perSystem
    #scoped inputs' so I can't acces them in my homeConfigurations
    #so until these are fixed I'm just adding them here.
    buggedModules = {
      spicetify-nix_module = inputs.spicetify-nix.homeManagerModule;
      nur_module = inputs.nur.hmModules.nur;
      nix-index-db_module = inputs.nix-index-db.hmModules.nix-index ;
    };
>>>>>>> 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)

    sharedModules = withSystem "x86_64-linux" ({ inputs', self', ...}:
      {
        imports = [
            self'.homeManagerModules.shells
            buggedModules.nur_module
            buggedModules.nix-index-db_module
          ];

        config = {
          home.shells = {
            zsh = true;
            starship = true;
          };
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
<<<<<<< HEAD
    homeConfigurations = withSystem "x86_64-linux" ({pkgs, ...}: {
      miobox = homeManagerConfiguration {
        modules = homeImports.miobox;
        inherit pkgs;
||||||| parent of 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
    homeConfigurations = withSystem "x86_64-linux" ({pkgs, ...}: {
      miobox = homeManagerConfiguration {
        modules = homeImports.miobox ++ module_args;
        inherit pkgs;
=======
    homeConfigurations = withSystem "x86_64-linux" ({pkgs, self', inputs', ...}: let
      extraSpecialArgs = {
        inherit inputs' self' default;
        inherit (buggedModules) spicetify-nix_module eww_module;
>>>>>>> 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
      };
<<<<<<< HEAD
      server = homeManagerConfiguration {
        modules = homeImports.server;
        inherit pkgs;
||||||| parent of 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
      server = homeManagerConfiguration {
        modules = homeImports.server ++ module_args;
        inherit pkgs;
=======

    in {
      desktop = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          self'.homeManagerModules.applications
          self'.homeManagerModules.desktop
          ./homestation/mikilio.nix
          sharedModules
        ];
      };

      minimal = homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          sharedModules
        ];
>>>>>>> 740415e (added plymouth again and improved prepare-install to reduce error accosiated with hardware-configuration.nix and reformating the disks)
      };
    });
  };
}
