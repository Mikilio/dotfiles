{
  config,
  lib,
  ...
}:
# networking configuration
{
  networking = {
    firewall = {
      trustedInterfaces = ["tailscale0"];
      # required to connect to Tailscale exit nodes
      checkReversePath = "loose";
      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = true;
    };

    nameservers = [
      "45.90.28.0#193dfc.dns.nextdns.io"
      "2a07:a8c0::#193dfc.dns.nextdns.io"
      "45.90.30.0#193dfc.dns.nextdns.io"
      "2a07:a8c1::#193dfc.dns.nextdns.io"
    ];
  };

  services = {
    # network discovery, mDNS
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };

    openssh = {
      enable = true;
      settings.UseDns = true;
    };

    # DNS resolver
    resolved.enable = true;
    resolved.dnsovertls = "true";

    # inter-machine VPN
    tailscale.enable = true;
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
