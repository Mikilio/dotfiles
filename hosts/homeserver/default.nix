{
  config,
  pkgs,
  lib,
  self,
  self',
  inputs',
  ...
} @ args: let
  
#list of users declared inside container
  container_users = {
    nextcloud = 999;
    inherit (config.ids.uids) murmur nginx;
  };
  container_groups = {
    nextcloud = 999;
    inherit (config.ids.gids) murmur nginx;
  };

  get_static_groups = groups: builtins.mapAttrs (name: value: { gid = value;}) (
    lib.attrsets.filterAttrs (n: v: builtins.elem  n groups) container_groups
  );

  get_static_users = users: builtins.mapAttrs (name: value: {
    uid = value;
    group = name;
    isSystemUser = true;
  }) (
    lib.attrsets.filterAttrs (n: v: builtins.elem  n users) container_users
  );


in {
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
   systemd.network = {
    enable = true;
    # silly fix for the service failing on nixos rebuild
    wait-online.enable = lib.mkForce false;
    networks = {
      "40-enp3s0" = {
        matchConfig.Name = "enp3s0";
        networkConfig.DHCP = "yes";
      };
    };
  };
  networking = {
    hostName = "homeserver"; # Define your hostname.
    networkmanager.enable = false;
    useNetworkd = true;
    # nameservers = [
    #   "1.1.1.1"
    #   "1.0.0.1"
    # ];
  };
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
      ];
      authKeyFile = config.sops.secrets.tailscale.path;
    };
  };

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = false;
    macvlans = [ "enp3s0" ];
    bindMounts = {
      tailscale = {
        isReadOnly = true;
        hostPath =  config.sops.secrets.tailscale.path;
        mountPoint = "/run/secrets/tailscale";
      };
      adminpass = {
        isReadOnly = false;
        hostPath =  config.sops.secrets.nextcloud_adminpass.path;
        mountPoint = "/run/secrets/adminpass";
      };
      dbpass = {
        isReadOnly = false;
        hostPath =  config.sops.secrets.nextcloud_dbpass.path;
        mountPoint = "/run/secrets/dbpass";
      };
      ssl_crt = {
        isReadOnly = true;
        hostPath =  config.sops.secrets.nextcloud_ssl_crt.path;
        mountPoint = "/run/secrets/ssl_crt";
      };
      ssl_key = {
        isReadOnly = true;
        hostPath =  config.sops.secrets.nextcloud_ssl_key.path;
        mountPoint = "/run/secrets/ssl_key";
      };
    };
    config = { config, pkgs, lib, ... }: {

      services = {
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud28;
          https = true;
          hostName = "nextcloud.batfish-vibe.ts.net";
          configureRedis = true;
          autoUpdateApps.enable = true;
          autoUpdateApps.startAt = "04:00:00";
          config = {
            # Nextcloud PostegreSQL database configuration, recommended over using SQLite
            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
            dbname = "nextcloud";
            dbpassFile = "/run/secrets/dbpass";
            adminpassFile = "/run/secrets/adminpass";
            adminuser = "admin";
          };
          settings = {
            # Further forces Nextcloud to use HTTPS
            overwriteProtocol = "https";

            trusted_domains = [ "nextcloud.batfish-vibe.ts.net" ];
          };
        };
        nginx.virtualHosts.${config.services.nextcloud.hostName} = {
          forceSSL = true;
          sslCertificate = "/run/secrets/ssl_crt";
          sslCertificateKey = "/run/secrets/ssl_key";
        };
        postgresql = {
          enable = true;

          # Ensure the database, user, and permissions always exist
          ensureDatabases = [ "nextcloud" ];
          ensureUsers = [{ 
              name = "nextcloud";
              ensureDBOwnership = true;
              ensureClauses = {
                createrole = true;
                createdb = true;
              };
          }];
        };

        tailscale = {
          enable = true;
          openFirewall = true;
          interfaceName = "userspace-networking";
          authKeyFile = "/run/secrets/tailscale";
        };
      };
      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };


      users.groups = lib.mkDefault (get_static_groups [ "nginx" "nextcloud"]);
      users.users = lib.mkDefault (get_static_users [ "nginx" "nextcloud"]);

      system.stateVersion = "23.11";

      networking = {
        useDHCP = false;
        useNetworkd = true;
        # interfaces.mvlan = {
        #   ipv4.addresses = [ { address = "192.168.0.130"; prefixLength = 24; } ];
        # };
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 443 ];
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

      environment.systemPackages = [ (pkgs.php.withExtensions ({ enabled, all }:
        enabled ++ [ all.curl all.soap ]))
      ];

    };
  };

  containers.murmur = {
    autoStart = true;
    privateNetwork = false;
    macvlans = [ "enp3s0" ];
    bindMounts = {
      tailscale = {
        isReadOnly = true;
        hostPath =  config.sops.secrets.tailscale.path;
        mountPoint = "/run/secrets/tailscale";
      };
    };
    config = { config, pkgs, lib, ... }: {

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

      users.groups = lib.mkDefault (get_static_groups [ "murmur" ]);
      users.users = lib.mkDefault (get_static_users [ "murmur"]);

      system.stateVersion = "23.11";

      networking = {
        useDHCP = false;
        useNetworkd = true;
        # interfaces.mvlan = {
        #   ipv4.addresses = [ { address = "192.168.0.131"; prefixLength = 24; } ];
        # };
        firewall = {
          enable = true;
          allowedTCPPorts = [ config.services.murmur.port ];
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
  
  users.groups = (get_static_groups (builtins.attrNames container_groups));
  users.mutableUsers = false;
  users.users = get_static_users (builtins.attrNames container_users) // {
    admin = {
      isNormalUser = true;
      extraGroups = ["libvirtd" "cloudflared" "wheel"];
      packages = [ pkgs.cloudflared pkgs.sops pkgs.vim];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeey5GyUUFlBdgghUeSdnUkxsMJad4rg8mOf2QBFmsa cardno:23_674_753"
      ];
    };
  };
}
