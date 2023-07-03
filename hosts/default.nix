{
  inputs,
  withSystem,
  sharedModules,
  desktopModules,
  homeImports,
  ...
}: {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({
    system,
    self',
    inputs',
    ...
  }: let
    systemInputs = [{_module.args = {inherit self' inputs';};}];
  in {
    homestation = inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          ./homestation
          ../modules/greetd.nix
          ../modules/desktop.nix
          ../modules/gamemode.nix
          /* inputs.lanzaboote.nixosModules.lanzaboote */
          {home-manager.users.mikilio.imports = homeImports.miobox;}
        ]
        ++ sharedModules
        ++ desktopModules
        ++ systemInputs;
    };
  });
}
