{
  "Captain Commodore" = {
    connection = {
      id = "Captain Commodore";
      interface-name = "wlp1s0";
      timestamp = "1719290667";
      type = "wifi";
      uuid = "9c9ca447-bdf6-4ff1-ad88-82df23093953";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
    };
    proxy = {};
    wifi = {
      mode = "infrastructure";
      ssid = "Captain Commodore";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk-flags = "1";
    };
  };
  "Mi A3" = {
    connection = {
      id = "Mi A3";
      interface-name = "wlp1s0";
      type = "wifi";
      uuid = "9470c9eb-44ea-478d-b112-9b81c02caefa";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = {};
    wifi = {
      mode = "infrastructure";
      ssid = "Mi A3";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk-flags = "1";
    };
  };
  PHX-5G-Guest = {
    connection = {
      id = "PHX-5G-Guest";
      type = "wifi";
      uuid = "eb9e81aa-2b05-4e5c-af22-5746b2f5e7db";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
    };
    proxy = {};
    wifi = {
      mode = "infrastructure";
      ssid = "PHX-5G-Guest";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk-flags = "1";
    };
  };
  WLAN-260804 = {
    connection = {
      id = "WLAN-260804";
      interface-name = "wlp1s0";
      type = "wifi";
      uuid = "8326f95a-411b-400c-9e18-3105421a2ac0";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = {};
    wifi = {
      mode = "infrastructure";
      ssid = "WLAN-260804";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk-flags = "1";
    };
  };
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
      address1 = "10.10.0.100/32";
      dns = "10.10.0.1;";
      dns-search = "~dr01;~duckrabbit.de;";
      method = "manual";
      never-default = "true";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "disabled";
    };
    wireguard = {
      private-key-flags = "1";
    };
    "wireguard-peer.b+eYajv8KuYZHEGbcXJs7fTv6+jhg52LLb3/kgzTvCw=" = {
      allowed-ips = "10.10.0.1/32;192.168.128.0/17;185.237.24.15/32;";
      endpoint = "176.9.139.62:54545";
      persistent-keepalive = "25";
    };
  };
}
