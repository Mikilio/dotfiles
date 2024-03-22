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
  };

  # virtualisation
  virtualisation.libvirtd.enable = true;

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = "admin";
      extraUpFlags = [ "--ssh"];
      authKeyFile = config.sops.secrets.tailscale.path;
    };
  };

  users.mutableUsers = false;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["libvirtd" "networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeey5GyUUFlBdgghUeSdnUkxsMJad4rg8mOf2QBFmsa cardno:23_674_753"
    ];

  };
}
