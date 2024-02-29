{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: hm @ {
    config,
    lib,
    pkgs,
    ...
  }:
  with lib; let
  in {
    config = {
      programs.khal = {
        enable = true;
        locale.weeknumbers = "left";
      };

      accounts.calendar = {
        basePath = "./.local/share/calendar";
        accounts = {
          home = {
            # primary = true;
            khal = {
              enable = true;
              type = "discover";
            };
            local = {
              type = "filesystem";
            };
            remote = {
              type = "google_calendar";
            };
            vdirsyncer = {
              enable = true;
              clientIdCommand = ["cat" "$XDG_PRIVATE_DIR/secrets/google-cal_id"];
              clientSecretCommand = ["cat" "$XDG_PRIVATE_DIR/secrets/google-cal_secret"];
            };
          };
        };
      };
    };
  }
)
