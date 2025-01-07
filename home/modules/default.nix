{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.modules.homeManager.default
    inputs.nix-index-db.hmModules.nix-index
    inputs.sops-nix.homeManagerModule
  ];

  config = {
    programs.nix-index-database.comma.enable = true;

    #NOTE: off till issue is fixed
    systemd.user.startServices = "sd-switch";

    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";
  };
}
