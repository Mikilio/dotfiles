# Thread model:
# Zero Trust
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.security.target;
in
{
  config = lib.mkIf (cfg == "server") {

    security = {
      tpm2 = {
        enable = true;
        abrmd.enable = true;
      };
    };
    services = {
      usbguard = {
        enable = false;
        ruleFile = config.sops.secrets.usbguard-rules.path;
      };
      # antivirus
      # enable antivirus clamav and
      # keep the signatures' database updated
      clamav = {
        daemon.enable = true;
        updater.enable = true;
      };
    };

    environment = {
      systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.system}.default
      ];
    };

    systemd.coredump.enable = false;
  };
}
