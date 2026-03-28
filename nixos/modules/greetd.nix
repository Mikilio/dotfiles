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
        greetd = {
          fprintAuth = false;
          u2fAuth = false;
          rules = let
            rule = {
              rosec = {
                control = "optional";
                order = 20000;
                modulePath = "${rosec}/lib/security/pam_mysql.so";
              };
            };
          in {
            auth = rule;
            session = rule;
            password = rule;
          };
        };
      };
    };
    environment =
      {
        systemPackages = [
          rosec
        ];
      }
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
