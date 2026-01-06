{
  lib,
  options,
  ...
}: {
  imports = [
    ./desktop.nix
    ./harden.nix
    ./server.nix
  ];
  options.dotfiles.security = {
    target = lib.mkOption {
      default = null;
      example = "server";
      description = "What kind of device is this intended for?";
      type = lib.types.nullOr lib.types.str;
    };
  };
  config =
    {}
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent" = {
          directories = [
            "/var/lib/tpm2-tss"
            "/var/lib/usbguard"
            "/var/lib/tpm2-udev-trigger"
          ];
        };
        "/persistent/cache" = {
          directories = [
            {
              directory = "/var/lib/clamav";
              user = "clamav";
              group = "clamav";
            }
          ];
        };
      };
    };
}
