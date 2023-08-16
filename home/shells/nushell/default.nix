{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.preferences.cli.shell;
in {
  config = mkIf (cfg == "nushell") {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
}
