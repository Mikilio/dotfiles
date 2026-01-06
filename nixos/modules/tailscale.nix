{
  config,
  lib,
  options,
  ...
}: let
  cfg = config.services.tailscale;
in {
  config =
    {
      networking.firewall = {
        trustedInterfaces = ["tailscale0"];
        # required to connect to Tailscale exit nodes
        checkReversePath = "loose";
        interfaces.${cfg.interfaceName}.allowedUDPPorts = [cfg.port];
      };

      # inter-machine VPN
      services.tailscale = {
        enable = true;
        openFirewall = false;
      };

      systemd.services.tailscaled.path = ["/run/wrappers"];
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/storage".files = [
          "/var/lib/tailscale/tailscale.state"
          "/var/lib/tailscale/tailscaled.log.conf"
        ];
        "/persistent/cache".directories = [
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
        ];
      };
    };
}
