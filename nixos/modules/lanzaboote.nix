{
  inputs,
  options,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config =
    {
      boot = {
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        # we let lanzaboote install systemd-boot
        loader.systemd-boot.enable = lib.mkForce false;
      };

      environment.systemPackages = [pkgs.sbctl];
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence."/persistent/storage".directories = ["/var/lib/sbctl"];
    };
}
