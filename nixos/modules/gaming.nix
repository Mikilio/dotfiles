{
  inputs,
    config,
    lib,
    pkgs,
    ...
}: {
  programs={
    steam = {
      enable = true;

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];

      # fix gamescope inside steam
      package = pkgs.steam;
    };
    gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 15;
        };
      };
    };
  };

  # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
  services.pipewire.lowLatency.enable = true;
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];
}
