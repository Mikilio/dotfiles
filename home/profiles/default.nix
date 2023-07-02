{
  inputs,
  withSystem,
  module_args,
  ...
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

  homeImports = {
    miobox =
      [
        ./miobox
        inputs.anyrun.homeManagerModules.default
        inputs.nix-index-db.hmModules.nix-index
        inputs.spicetify-nix.homeManagerModule
        inputs.hyprland.homeManagerModules.default
      ] ++ sharedModules;
    server = sharedModules ++ [./server];
  };

  inherit (inputs.hm.lib) homeManagerConfiguration;
in {
  imports = [
    {_module.args = {inherit homeImports;};}
  ];

  flake = {
    homeConfigurations = withSystem "x86_64-linux" ({pkgs, ...}: {
      miobox = homeManagerConfiguration {
        modules = homeImports.miobox ++ module_args;
        inherit pkgs;
      };
      server = homeManagerConfiguration {
        modules = homeImports.server ++ module_args;
        inherit pkgs;
      };
    });

    homeManagerModules.eww-hyprland = import ../programs/eww;
  };
}
