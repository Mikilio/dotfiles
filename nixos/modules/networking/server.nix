{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.dotfiles.networking;
in {
  config = lib.mkIf (cfg.target == "server") {
    systemd.network.enable = true;
    systemd.network.networks."10-wan" = {
      matchConfig.Name = cfg.physicalInterface;
      networkConfig.DHCP = "ipv4";
      address = [cfg.IPv6Identity];
      routes = [
        {routeConfig.Gateway = "fe80::1";}
      ];
    };
  };
}
