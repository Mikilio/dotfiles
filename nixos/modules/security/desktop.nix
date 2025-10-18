# Thread model:
# My personal computers are listening on no ports. All connections are outbound.
# My personal computers may connect to unsecure networks.
# My personal computer may be left unattended.
# My personal computer needs most debugging and developement capabilities.
# My personal computer may be used by multiple users.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.dotfiles.security.target;
in {
  config = lib.mkIf (cfg == "desktop") {
    security = {
      tpm2 = {
        enable = true;
        abrmd.enable = true;
      };
      #polkit
      polkit.enable = true;
    };
    services = {
      usbguard = {
        enable = true;
        dbus.enable = true;
        IPCAllowedGroups = ["wheel"];
        restoreControllerDeviceState = true;
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
      # Undo setting memory allocator to 'scudo'.
      # 'scudo' breaks the usage of firefox.
      memoryAllocator.provider = lib.mkForce "libc";
      systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.system}.default
      ];
    };

    # create system-wide executables firefox
    # that will wrap the real binaries so everything
    # work out of the box.
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        floorp = {
          executable = lib.getExe pkgs.floorp-bin;
          profile = "${pkgs.firejail}/etc/firejail/floorp.profile";
        };
        thunderbird = {
          executable = lib.getExe pkgs.thunderbird;
          profile = "${pkgs.firejail}/etc/firejail/thunderbird.profile";
        };
        mpv = {
          executable = "${lib.getBin pkgs.mpv}/bin/mpv";
          profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
        };
      };
    };

    systemd = {
      user.units.usbguard-notifier.wantedBy = ["graphical-session.target"];
      packages = [
        pkgs.usbguard-notifier
      ];
      coredump.enable = false;
    };
  };
}
