{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: let
in {
  config = {
    assertions = [{
      assertion = (
        builtins.length (lib.lists.intersectLists [22000 21027] osConfig.networking.firewall.allowedUDPPorts) == 2 &&
        builtins.length (lib.lists.intersectLists [22000 42355] osConfig.networking.firewall.allowedTCPPorts) == 2
      );
      message = ''
        Add the syncthing homeModule from Mikilio/dotfiles to open ports
      '';
    }];

    services.syncthing = {
      enable = true;
      extraOptions = [
        "--gui-apikey=${config.sops.secrets.syncthing-gui.path}"
      ];
    # this service is bad
    #   tray = {
    #     enable = true;
    #     command = "syncthingtray --wait";
    #   };
    };

    home.packages = [ pkgs.syncthingtray-minimal];
  };
}
