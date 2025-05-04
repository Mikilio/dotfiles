{ config, ... }:
let
  cfg = config.services.tailscale;
in
{
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    # required to connect to Tailscale exit nodes
    checkReversePath = "loose";
    interfaces.${cfg.interfaceName}.allowedUDPPorts = [ cfg.port ];
  };

  # inter-machine VPN
  services.tailscale = {
    enable = true;
    openFirewall = false;
  };

  systemd.services.tailscaled.path = [ "/run/wrappers" ];
}
