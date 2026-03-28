{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rosec;
  toTOML = lib.generators.toTOML {};
  configFile = pkgs.writeText "rosec.toml" (toTOML cfg.settings);
in {
  options.services.rosec = {
    enable = lib.mkEnableOption "rosec secrets daemon";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The rosec package to use";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
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

    # Generate config file if settings are provided
    xdg.configFile = lib.mkIf (cfg.settings != {}) {
      "rosec/config.toml".source = configFile;
    };
  };
}
