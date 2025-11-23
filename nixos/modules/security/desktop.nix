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
        rules = ''
          allow with-connect-type "hardwired"
          allow  with-interface one-of { 09:00:* }

          allow name "Thunderbolt 4 Docking Station" hash "HqQf+sgpLF/8YHofncFBdqEG4BmMHp37fViu8PE/Gns="
          allow if allowed-matches(serial "11AD1D0A08B6400E13280B00" name "Thunderbolt 4 Docking Station" hash "HqQf+sgpLF/8YHofncFBdqEG4BmMHp37fViu8PE/Gns=")

          allow name "YubiKey OTP+FIDO+CCID" hash "Q+A8QQReKclmBSaDIYja0w4Bx6ld2IU6wF7HFKdtJ3Q=" with-interface { 03:01:01 03:00:00 0b:00:00 }
        '';
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
        pkgs.sops
      ];
    };

    # create system-wide executables firefox
    # that will wrap the real binaries so everything
    # work out of the box.
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
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
