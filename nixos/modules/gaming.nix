{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        args = [ "--prefer-vk-device" "--prefer-output DP-8" ];
        env = {
          MESA_VK_DEVICE_SELECT = "1002:73df!";
        };
      };
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];

      # fix gamescope inside steam
      package = pkgs.steam;
    };
    gamescope.capSysNice = true;
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
  boot.extraModprobeConfig = ''options bluetooth disable_ertm=1 '';
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];
}
