{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.home.shells.nushell;
in {
  config = mkIf cfg {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
}
