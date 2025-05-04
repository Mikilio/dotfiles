{
  config,
  pkgs,
  lib,
  ezModules,
  modulesPath,
  inputs,
  ...
}:
{
  imports =
    [
      ./hardware-configuration.nix
      ./disk-config.nix
      ./secrets.nix
      inputs.disko.nixosModules.disko
      inputs.nixos-hardware.nixosModules.common-pc
      # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ]
    ++ (with ezModules; [
      pacman
      distro-testing
    ]);

  dotfiles.security.target = "server";
  dotfiles.networking.target = "server";

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      diskSize = 2048;
      graphics = false;
      qemu = {
        options = [

        ];
      };
      interfaces = {
        enp1s0 = {
          vlan = 1;
        };
      };
      forwardPorts = [
        # forward local port 2222 -> 22, to ssh into the VM
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
    services = {
      openssh = {
        enable = true;
        openFirewall = true;
      };
    };
  };

  containers = {
    kube = {
      config = { ... }: { };

    };
    org = {

      autoStart = true;
      privateNetwork = false;
      macvlans = [ "enp3s0" ];
      bindMounts = {
        tailscale = {
          isReadOnly = true;
          hostPath = config.sops.secrets.tailscale.path;
          mountPoint = "/run/secrets/tailscale";
        };
      };
      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          services = {
            tailscale = {
              enable = true;
              openFirewall = true;
              interfaceName = "userspace-networking";
              authKeyFile = "/run/secrets/tailscale";
            };
          };

          system.stateVersion = "23.11";

          networking = {
            useDHCP = false;
            useNetworkd = true;
            # interfaces.mvlan = {
            #   ipv4.addresses = [ { address = "192.168.0.131"; prefixLength = 24; } ];
            # };
            firewall = {
              enable = true;
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
  };

  services = {
    tailscale = {
      extraUpFlags = [
        "--ssh"
        "--advertise-tags=tag:server"
      ];
      authKeyFile = config.sops.secrets.tailscale.path;
    };
  };

  users.mutableUsers = false;
  users.users = {
    mikilio = {
      isNormalUser = true;
      password = "test";
      extraGroups = [
        "libvirtd"
        "cloudflared"
        "wheel"
      ];
      packages = [
        # pkgs.cloudflared
        pkgs.sops
        pkgs.vim
        pkgs.age
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYPjdpzOZCLJfSGaeMo7yYBmTTVSnjf04aB3K74qZN9zOBotyBmLqD+SzVBrvbmGH3byRZF1V5bWdckc9ttdeJnLGJBtBNpBoCEb7V9AufzUC6njka2pvw8yIrOJZmK7JHK/IY21Wjsagu10f4OdUWF+CRevLmECOK0CJQmzbpjksFqVB9vaCI6fTBm0ZD+/AezXideg4FDBnfzjvT/0WEJbYj9yV6UO7rNIx7mYIErCnTg3PUUMuNz1By3pUGBjXnhDogW9KgrDqGDYbkqalxiNOW35D0QyxiIBhqy96B1Irt+dIQPG2qj6uAsMqfAyycGyZ34QukxKbudE/j+F/JlmGAfB3wbS1zaIyASd3vV0nO8zp2fQcyyP2wkjYe/qB9QFnNDh6/OUANKtMdXwFL94ZYJd4ZVwxsVZPdFlCS34Jf10o4P0rXAEcsQplsHFo0bjxn5yySwjEl26HZKBKd7PYQ7hb/zMCVroqcmBLoqGLD5vDaeZ3EMvTIHw6Gumbg6TggLopCzdwNiUqYdqelXwVC/mdpdyOYP/aBzMuN7FzOkehC4p99Pn3tiS+saqmU6em5y4l+U722J9fuKppYIB1VvZY8sDLQlxXepUykNzj0wwJse9fcgZ8X2P48F4gg8OvjZJ/Efyygvi6xsFoSmsP5itC0PIUG95aLhE78vQ== cardno:23_674_753"
      ];
    };
  };
}
