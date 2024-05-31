{
  containers.wordpress = {
    autoStart = true;
    privateNetwork = false;
    macvlans = ["enp3s0"];
    bindMounts = {
      tailscale = {
        isReadOnly = true;
        hostPath = config.sops.secrets.tailscale.path;
        mountPoint = "/run/secrets/tailscale";
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services = {
        murmur = {
          port = 2052;
          enable = true;
          openFirewall = true;
          bandwidth = 256000;
        };
        tailscale = {
          enable = true;
          openFirewall = true;
          interfaceName = "userspace-networking";
          authKeyFile = "/run/secrets/tailscale";
        };
      };

      users.groups = lib.mkDefault (get_static_groups ["murmur"]);
      users.users = lib.mkDefault (get_static_users ["murmur"]);

      system.stateVersion = "23.11";

      networking = {
        useDHCP = false;
        useNetworkd = true;
        # interfaces.mvlan = {
        #   ipv4.addresses = [ { address = "192.168.0.131"; prefixLength = 24; } ];
        # };
        firewall = {
          enable = true;
          allowedTCPPorts = [config.services.murmur.port];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };
      systemd.network = {
        enable = true;
        networks = {
          "40-mv-enp3s0" = {
            matchConfig.Name = "mv-enp3s0";
            address = [
              "192.168.0.131/24"
            ];
            networkConfig.DHCP = "yes";
            dhcpV4Config.ClientIdentifier = "mac";
          };
        };
      };

      services.resolved.enable = true;
    };
  };
}
