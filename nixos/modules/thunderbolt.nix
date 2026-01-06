{
  pkgs,
  lib,
  options,
  ...
}: {
  config =
    {
      boot = {
        initrd.kernelModules = ["thunderbolt"];
        kernelModules = ["thunderbolt"];
      };

      services.hardware.bolt.enable = true;
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/storage" = {
          directories = ["/var/lib/boltd/devices"];
        };
        "/persistent/cache" = {
          directories = ["/var/lib/boltd/times"];
        };
      };
    };
}
