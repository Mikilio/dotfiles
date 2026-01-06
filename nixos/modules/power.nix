{
  lib,
  options,
  ...
}: {
  config =
    {
      services = {
        logind.settings.Login.HandlePowerKey = "suspend";

        power-profiles-daemon.enable = true;

        # battery info
        upower.enable = true;
      };
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/storage".directories = [
          "/var/lib/upower"
        ];
        "/persistent/cache".directories = [
          "/var/lib/power-profiles-daemon"
        ];
      };
    };
}
