{
  lib,
  config,
  options,
  ...
}: let
  cfg = config.dotfiles.networking;
in {
  config = lib.mkIf (cfg.target == "desktop") ({
      # client networking configuration
      networking = {
        firewall = {
          # if packets are still dropped, they will show up in dmesg
          logReversePathDrops = true;
        };

        nameservers = [
          "45.90.28.0#193dfc.dns.nextdns.io"
          "2a07:a8c0::#193dfc.dns.nextdns.io"
          "45.90.30.0#193dfc.dns.nextdns.io"
          "2a07:a8c1::#193dfc.dns.nextdns.io"
        ];

        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
          settings = {
            wifi-security.psk-flags = "1";
          };
        };

        # to setup networks and infrastructure shenanigans
        nftables.enable = true;
      };

      services = {
        #Allow ssh from self
        openssh = {
          enable = true;
          openFirewall = false;
        };
        # DNS resolver
        resolved = {
          enable = true;
          dnsovertls = "true";
          dnssec = "allow-downgrade";
        };
      };
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent" = {
          directories = [
            {
              directory = "/etc/NetworkManager/system-connections";
              mode = "0700";
            }
          ];
        };
        "/persistent/cache" = {
          directories = [
            "/var/lib/nftables"
            "/var/lib/NetworkManager"
          ];
          files = ["/var/lib/NetworkManager/seen-bssids"];
        };
      };
    });
}
