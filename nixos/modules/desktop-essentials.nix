{ pkgs, ... }:
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
