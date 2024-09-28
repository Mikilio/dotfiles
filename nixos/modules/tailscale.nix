{ config, lib, ... }:
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

  systemd.services.tailscaled.path = ["/run/wrappers"];

  # systemd.services.tailscaled.environment.PATH = with lib;
  #   let
  #     su = "${config.security.wrapperDir}/${config.security.wrappers.su.program}";
  #     cfg = config.systemd.services.tailscaled;
  #   in mkOverride 99 "${makeBinPath cfg.path}:${makeSearchPathOutput "bin" "sbin" cfg.path}:${su}";
}
