{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez5-experimental;
    settings = {
      # make Xbox Series X controller work
      General = {
        Class = "0x000100";
        FastConnectable = true;
        JustWorksRepairing = "always";
        Privacy = "device";
        KernelExperimental = true;
        # Battery info for Bluetooth devices
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/114222
  systemd.user.services.telephony_client.enable = false;
}
