{
  inputs,
  osConfig,
  config,
  ...
}: {
  imports = [
    inputs.nur.hmModules.nur
    inputs.nix-index-db.hmModules.nix-index
    inputs.sops-nix.homeManagerModule
  ];

  config = {
    programs.nix-index-database.comma.enable = true;

    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;

    nixpkgs = {inherit (osConfig.nixpkgs) config overlays;};

    home.stateVersion = "23.11";
  };
}
