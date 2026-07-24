{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rosec;

  format = pkgs.formats.toml {};
in {
  options.services.rosec = {
    enable = lib.mkEnableOption "rosec secrets daemon";

    package = lib.mkPackageOption pkgs "rosec" {};

    settings = lib.mkOption {
      type = format.type;
      default = {};
      description = ''
        Configuration for rosec in Nix attribute set format.
        This will be converted to TOML and written to the config file.

        See https://github.com/jmylchreest/rosec for available options.
      '';
      example = lib.literalExpression ''
        {
          general = {
            log_level = "info";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Add rosec to D-Bus packages
    dbus.packages = [cfg.package];

    home.packages = [cfg.package];

    xdg.portal = {
      config.common."org.freedesktop.impl.portal.Secret" = ["rosec"];
      extraPortals = [cfg.package];
    };

    # Generate config file if settings are provided
    xdg.configFile = lib.mkIf (cfg.settings != {}) {
      "rosec/config.toml".source = format.generate "config.toml" cfg.settings;
    };
  };
}
