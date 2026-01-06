{
  pkgs,
  lib,
  options,
  ...
}: {
  config =
    {
      environment.systemPackages = with pkgs; [
        pcscliteWithPolkit
      ];

      services = {
        # needed for GNOME services outside of GNOME Desktop
        dbus.packages = with pkgs; [
          gcr
          gnome-settings-daemon
        ];

        gvfs.enable = true;

        #Proper disk mounting
        udisks2 = {
          enable = true;
          mountOnMedia = true;
        };
        davfs2.enable = true;

        printing.enable = true;
        # smart card deamon
        pcscd.enable = true;
        #secure usb devices
        fwupd.enable = true;
      };

      programs = {
        gnome-disks.enable = true;
        # make HM-managed GTK stuff work
        dconf.enable = true;
      };
    }
    // lib.optionalAttrs (options.environment?persistence)
    {
      environment.persistence = {
        "/persistent/storage" = {
          directories = [
            {
              directory = "/var/lib/fwupd/gnupg";
              user = "root";
              mode = "0700";
            }
            {
              directory = "/var/lib/fwupd/pki";
              user = "root";
            }
            {
              directory = "/var/lib/cups/ppd";
              user = "root";
              group = "lp";
              mode = "0755";
            }
            {
              directory = "/var/lib/cups/ssl";
              user = "root";
              group = "lp";
              mode = "0700";
            }
          ];
          files = [
            "/var/lib/cups/lpoptions"
            "/var/lib/cups/printers.conf"
          ];
        };
        "/persistent/cache" = {
          directories = [
            "/var/lib/udisks2"
            "/var/cache/fwupd"
            {
              directory = "/var/lib/fwupd/metadata";
              user = "root";
            }
          ];
        };
        "/persistent/volatile" = {
          files = [
              "/var/lib/fwupd/pending.db"
          ];
        };
      };
    };
}
