{
  eduroam = {
    "802-1x" = {
      anonymous-identity = "anonymous";
      domain-suffix-match = "radius.lrz.de";
      eap = "peap;";
      identity = "ga84tet@eduroam.mwn.de";
      password-flags = "1";
      phase2-auth = "mschapv2";
    };
    connection = {
      id = "eduroam";
      interface-name = "wlp1s0";
      type = "wifi";
      uuid = "082521d4-67c1-4866-8c85-a3593a5ec026";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
    };
    proxy = { };
    wifi = {
      mode = "infrastructure";
      ssid = "eduroam";
    };
    wifi-security = {
      key-mgmt = "wpa-eap";
    };
  };
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
    proxy = { };
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
    proxy = { };
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
    proxy = { };
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
    proxy = { };
    wifi = {
      mode = "infrastructure";
      ssid = "WLAN-260804";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk-flags = "1";
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
  eduVPN = {
    connection = {
      autoconnect = "false";
      id = "eduVPN";
      interface-name = "eduVPN";
      permissions = "user:mikilio:;";
      dns-over-tls = 0;
      type = "wireguard";
      uuid = "f8f492b1-e359-4ca1-9ce7-3debcfb8e866";
    };
    ipv4 = {
      address1 = "10.157.60.16/23";
      dns = "10.156.33.53;129.187.5.1;";
      dns-search = "tum.de;tu-muenchen.de;";
      method = "manual";
      never-default = "true";
      route-table = "51860";
      routing-rule1 = "priority 1 not from 0.0.0.0/0 fwmark 0xca94 table 51860";
    };
    ipv6 = {
      addr-gen-mode = "default";
      address1 = "2001:4ca0:2fff:2:6::10/96";
      dns = "2001:4ca0::53:1;2001:4ca0::53:2;";
      dns-search = "tum.de;tu-muenchen.de;";
      method = "manual";
      never-default = "true";
      route-table = "51860";
      routing-rule1 = "priority 1 not from ::/0 fwmark 0xca94 table 51860";
    };
    proxy = { };
    wireguard = {
      fwmark = "51860";
      ip4-auto-default-route = "0";
      ip6-auto-default-route = "0";
      mtu = "1392";
      private-key = "sG2Q6RnPLIt+ud7/vFiG9i+bGXB3ih0wbVT0kZ5z8F4=";
    };
    "wireguard-peer.PyClbN5SjrfYcdsfTpdOCLs0eHM0iZME7s1r+8d+dGo=" = {
      allowed-ips = "10.0.0.0/8;85.208.24.0/22;129.187.0.0/16;131.159.0.0/16;131.188.16.200/32;132.187.1.70/32;138.244.0.0/15;138.246.0.0/16;141.39.128.0/18;141.39.240.0/20;141.40.0.0/16;141.84.0.0/16;172.16.0.0/12;192.54.42.0/24;192.55.197.0/24;192.68.211.0/24;192.68.212.0/24;192.168.0.0/16;193.174.96.0/23;194.94.155.224/28;2001:4ca0::/29;2a09:80c0::/29;";
      endpoint = "eduvpn-n12.srv.lrz.de:51820";
    };
  };
}
