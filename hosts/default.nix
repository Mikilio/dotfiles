{
  theme,
  inputs,
  lib,
  self,
  withSystem,
  sharedModules,
  ...
}:
with lib; {
  flake.nixosConfigurations = withSystem "x86_64-linux" ({
    system,
    self',
    inputs',
    ...
  }: {
    elitebook = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self inputs self' inputs' theme; };
      modules = [ ./elitebook ];
    };
    workstation = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self inputs self' inputs' theme; };
      modules = [ ./workstation ];
    };
    homeserver = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self inputs self' inputs'; };
      modules = [ ./homeserver ];
    };
  });
}
