{
  pkgs,
  lib,
  options,
  inputs,
  ...
}: let
  inherit (pkgs.nur.repos.mikilio) rosec;
in {
  config = {
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

    services = {
      fprintd.enable = true;
      rosec = {
        enable = true;
        pam.enable = true;
      };
    };

    security.pam = {
      u2f = {
        enable = true;
        settings = {
          cue = true;
        };
      };
      services = {
        greetd = {
          fprintAuth = false;
          u2fAuth = false;
        };
      };
    };
    environment =
      {}
      // lib.optionalAttrs (options.environment?persistence)
      {
        persistence = {
          "/persistent/storage" = {
            directories = [
              {
                directory = "/var/lib/regreet";
                user = "greeter";
                group = "greeter";
              }
              {
                directory = "/var/lib/fprint";
                mode = "0700";
              }
            ];
          };
          "/persistent/cache" = {
            directories = [
              "/var/cache/regreet"
            ];
          };
          "/persistent/volatile" = {
            files = [
              "/var/lib/lastlog/lastlog2.db"
            ];
          };
        };
      };
  };
}
