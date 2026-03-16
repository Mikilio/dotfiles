{
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  config = {
    programs.virt-manager.enable = true;
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;
      containers = {
        enable = true;
        storage.settings = {
          storage = {
            driver = "btrfs";
            runroot = "/run/containers/storage";
            graphroot = "/var/lib/containers/storage";
            options.overlay.mountopt = "nodev,metacopy=on";
          };
        };
      };
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };
    services.spice-vdagentd.enable = true;
    networking.firewall = {
      trustedInterfaces = ["virbr0"];
      interfaces."podman*".allowedUDPPorts = [53];
    };

    security.unprivilegedUsernsClone = true;
    environment =
      {
        systemPackages = with pkgs; [
          dive # look into docker image layers
          podman-tui # Terminal mgmt UI for Podman
          docker-compose
          passt # For Pasta rootless networking
        ];
        extraInit = ''
          if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
            export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
          fi
        '';

        # https://github.com/nikstur/userborn/issues/7
        etc = let
          autosubs = lib.pipe config.users.users [
            lib.attrValues
            (lib.filter (u: u.autoSubUidGidRange))
            (lib.lists.imap0 (i: u: "${u.name}:${toString (100000 + i * 65536)}:65536\n"))
            lib.concatStrings
          ];
        in
          lib.mkIf config.services.userborn.enable {
            "subuid".text = autosubs;
            "subuid".mode = "0444";
            "subgid".text = autosubs;
            "subgid".mode = "0444";
          };
      }
      // lib.optionalAttrs (options.environment?persistence)
      {
        persistence = {
          "/persistent/storage" = {
            directories = [
              "/var/lib/libvirt"
              {
                directory = "/var/lib/swtpm-localca";
                user = "tss";
                group = "tss";
              }
            ];
          };
          "/persistent/cache" = {
            directories = [
              "/var/lib/containers"
              "/var/lib/libvirt/dnsmasq"
            ];
          };
          "/persistent/volatile" = {
            directories = [
              {
                directory = "/var/lib/libvirt/images";
                mode = "0711";
              }
            ];
          };
        };
      };
  };
}
