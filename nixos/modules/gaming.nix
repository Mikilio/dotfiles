{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
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

  services = {
    # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
    pipewire.lowLatency.enable = true;
  };

  hardware = {
    steam-hardware.enable = true;
  };
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];
}
