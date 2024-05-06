# WARNING: This file is generaly not usable as a module yet
{
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
            defaultPhoneRegion = "DE";
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
}
