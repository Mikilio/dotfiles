{
  config,
  pkgs,
  lib,
  self,
  self',
  inputs',
  ...
} @ args: {
  imports = [./hardware-configuration.nix ./disk-config.nix ./secrets.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
 #  hardware.nvidia = {
	#
 #    # Modesetting is required.
 #    modesetting.enable = true;
	#
 #    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
 #    # Enable this if you have graphical corruption issues or application crashes after waking
 #    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
 #    # of just the bare essentials.
 #    powerManagement.enable = true;
	#
 #    # Fine-grained power management. Turns off GPU when not in use.
 #    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
 #    powerManagement.finegrained = false;
	#
 #    # Use the NVidia open source kernel module (not to be confused with the
 #    # independent third-party "nouveau" open source driver).
 #    # Support is limited to the Turing and later architectures. Full list of 
 #    # supported GPUs is at: 
 #    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
 #    # Only available from driver 515.43.04+
 #    # Currently alpha-quality/buggy, so false is currently the recommended setting.
 #    open = false;
	#
 #    # Enable the Nvidia settings menu,
	# # accessible via `nvidia-settings`.
 #    nvidiaSettings = true;
 #  };
	#
  networking = {
    hostName = "homeserver";
    useNetworkd = true;

    macvlans.mvlan-host = {
      interface = "enp3s0";
      mode = "bridge";
    };
    interfaces = {
      enp3s0.ipv4.addresses = lib.mkForce [];
      mvlan-host = {
        ipv4.addresses = [ { address = "192.168.0.128"; prefixLength = 24; } ];
      };
    };
  };
  systemd.network.wait-online.enable = lib.mkForce false;

  # virtualisation
  virtualisation.libvirtd.enable = true;

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = "admin";
      extraUpFlags = [
        "--ssh"
        "--operator=admin"
        "--advertise-routes=192.168.0.0/24"
      ];
      authKeyFile = config.sops.secrets.tailscale.path;
    };
    cloudflared = {
      enable = true;
      user = "admin";
      tunnels = {
        #murmur
        "91bbb740-87ab-41f2-b890-46365ae1e234" = {
          default = "tcp://192.168.0.131:2052"; 
          credentialsFile = config.sops.secrets.cloudflare_murmur.path;
        };
        #next
        "6f3e2a91-a1a6-4dfa-81c1-3a223c61274c" = {
          default = "http://192.168.0.130:80"; 
          credentialsFile = config.sops.secrets.cloudflare_next.path;
        };
      };
    };
  };

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = false;
    macvlans = [ "enp3s0" ];
    config = { config, pkgs, lib, ... }: {

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud28;
        https = true;
        hostName = "next.tlecloud.com";
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
        settings = {
          trusted_domains = [ "192.168.0.130" ];
          trusted_proxies = [ "6f3e2a91-a1a6-4dfa-81c1-3a223c61274c.cfargotunnel.com" ];
        };
      };

      system.stateVersion = "23.11";

      networking = {
        useDHCP = false;
        useNetworkd = true;
        # interfaces.mvlan = {
        #   ipv4.addresses = [ { address = "192.168.0.130"; prefixLength = 24; } ];
        # };
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 ];
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
              "192.168.0.130/24"
            ];
            networkConfig.DHCP = "yes";
            dhcpV4Config.ClientIdentifier = "mac";
          };
        };
      };
      services.resolved.enable = true;

    };
  };

  containers.murmur = let
    #this port is supported by cloudflare
    port = 2052;
  in{
    autoStart = true;
    privateNetwork = false;
    macvlans = [ "enp3s0" ];
    bindMounts = {
      crt = {
        isReadOnly = true;
        hostPath = config.sops.secrets.ssl_cert.path;
        mountPoint = "/etc/ssl/certs/cloudflare.crt";
      };
      key = {
        isReadOnly = true;
        hostPath = config.sops.secrets.ssl_key.path;
        mountPoint = "/etc/ssl/keys/cloudflare.key";
      };
    };
    config = { config, pkgs, lib, ... }: {

      services.murmur = {
        inherit port;
        enable = true;
        openFirewall = true;
        bandwidth = 256000;
        registerName = "TLe";
        registerHostname = "mumble.tlecloud.com";
        sslCert = "/etc/ssl/certs/cloudflare.crt";
        sslKey = "/etc/ssl/keys/cloudflare.key";
      };

      users.groups.ssl = {
        gid = 992;
      };
      users.users.murmur.extraGroups = [ "ssl" ];

      system.stateVersion = "23.11";

      networking = {
        useDHCP = false;
        useNetworkd = true;
        # interfaces.mvlan = {
        #   ipv4.addresses = [ { address = "192.168.0.131"; prefixLength = 24; } ];
        # };
        firewall = {
          enable = true;
          allowedTCPPorts = [ port ];
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

  users.groups.ssl = {
    gid = 992;
  };

  users.mutableUsers = false;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["libvirtd" "cloudflared" "wheel"];
    packages = [ pkgs.cloudflared ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeey5GyUUFlBdgghUeSdnUkxsMJad4rg8mOf2QBFmsa cardno:23_674_753"
    ];

  };
}
