{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.preferences.cli.shell;
in
  mkIf (!isNull cfg) {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      matchBlocks = {
        uni = {
          hostname = "lxhalle.in.tum.de";
          user = "mio";
          forwardX11 = true;
        };
      };

      extraConfig = "XAuthLocation ${pkgs.xorg.xauth}/bin/xauth";
    };
  }
