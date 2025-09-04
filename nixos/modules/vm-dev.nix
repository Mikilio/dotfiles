{ pkgs, ... }:
{

  programs.virt-manager.enable = true;
  environment = {
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
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
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
    trustedInterfaces = [ "virbr0" ];
    interfaces."podman*".allowedUDPPorts = [53];
  };

  security.unprivilegedUsernsClone = true;
}
