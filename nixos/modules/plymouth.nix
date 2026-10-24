{
  lib,
  options,
  ...
}: {
  config =
    {
      # Early KMS: load the amdgpu driver in stage 1 so Plymouth and the LUKS
      # prompt render at native resolution. nixos-facter does not do this.
      hardware.amdgpu.initrd.enable = true;

      boot = {
        plymouth = {
          enable = true;
        };

        # Enable "Silent Boot"
        consoleLogLevel = 0;
        kernelParams = [
          "quiet"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
      };
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/cache" = {
          directories = [
            "/var/lib/plymouth"
          ];
        };
      };
    };
}
