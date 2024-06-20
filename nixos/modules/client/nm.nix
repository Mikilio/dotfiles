{
  TUM = {
    connection = {
      id = "university";
      type = "vpn";
      uuid = "a2bdbfe1-d10f-40f4-9c66-e4dc1ffde2e4";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
    };
    proxy = {};
    vpn = {
      ca = "/home/mikilio/.cert/nm-openvpn/vpn-rbg-2.4-linux-ca.pem";
      connection-type = "password";
      dev = "tun";
      password-flags = "1";
      remote = "rbg.vpn.rbg.tum.de:1128";
      service-type = "org.freedesktop.NetworkManager.openvpn";
    };
  };
  DuckRabbit = {
    connection = {
      id = "duckrabbit";
      interface-name = "wg0";
      permissions = "user:mikilio:;";
      type = "wireguard";
      uuid = "7adc7fc2-519a-443f-8ffd-9fea187f55ab";
      dns-over-tls = 0;
    };
    ipv4 = {
      address1 = "10.10.0.104/32";
      dns = "10.10.0.1;";
      dns-search = "~dr01;";
      method = "manual";
      never-default = "true";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "disabled";
    };
    wireguard = {
      private-key-flag = 1;
    };
    "wireguard-peer.b+eYajv8KuYZHEGbcXJs7fTv6+jhg52LLb3/kgzTvCw=" = {
      allowed-ips = "10.10.0.1/32;192.168.128.0/17;185.237.24.15/32;";
      endpoint = "176.9.139.62:54545";
      persistent-keepalive = "25";
    };
  };
}
