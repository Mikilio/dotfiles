{
  pkgs,
  lib,
  options,
  ...
}: {
  config =
    {
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

      # https://github.com/NixOS/nixpkgs/issues/114222
      systemd.user.services.telephony_client.enable = false;
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/storage" = {
          directories = [
            {
              directory = "/var/lib/bluetooth";
              mode = "0700";
            }
          ];
        };
      };
    };
}
