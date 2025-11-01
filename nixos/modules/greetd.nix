{
  pkgs,
  config,
  ...
}: {
  config = {
    programs.regreet = {
      enable = true;
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
    };

    services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      ACTION=="add",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl unlock-sessions"
    '';

    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
    services.fprintd.enable = true;

    security.pam = {
      u2f = {
        enable = true;
        settings = {
          cue = true;
        };
      };
      services = {
        greetd.fprintAuth = false;
      };
    };
  };
}
