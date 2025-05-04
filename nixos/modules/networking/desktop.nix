{ lib, config, ... }:
with lib;

let
  cfg = config.dotfiles.networking.target;
in
{
  config = lib.mkIf (cfg == "desktop") {
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
        ensureProfiles.profiles = import ./nm.nix;
      };

      # to setup networks and infrastructure shenanigans
      nftables.enable = true;
    };

    services = {
      # DNS resolver
      resolved = {
        enable = true;
        dnsovertls = "true";
        dnssec = "allow-downgrade";
      };
    };
    # Don't wait for network startup
    # systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  };
}
