_ : {
  # client networking configuration
  #NOTE: this config really only makes sense for mikilios devices

  networking = {
    firewall = {
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 54545 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 54545 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 54545 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 54545 -j RETURN || true
      '';
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };

    dhcpcd.denyInterfaces = ["wg0"];

    nameservers = [
      "45.90.28.0#193dfc.dns.nextdns.io"
      "2a07:a8c0::#193dfc.dns.nextdns.io"
      "45.90.30.0#193dfc.dns.nextdns.io"
      "2a07:a8c1::#193dfc.dns.nextdns.io"
    ];

    networkmanager.ensureProfiles.profiles = import ./nm.nix;
  };

  programs.nm-applet.enable = true;

  services = {
    # DNS resolver
    resolved.enable = true;
    resolved.dnsovertls = "true";
  };

  # Don't wait for network startup
  # systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
