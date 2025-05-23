{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    programs.regreet = {
      enable = true;
      settings = {
        GTK.application_prefer_dark_theme = true;
      };
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

    security.pam = {
      u2f = {
        enable = true;
        settings.cue = true;
      };
      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
    };
  };
}
