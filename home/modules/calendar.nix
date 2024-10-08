{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
#TODO: do something other than nextcloud because we hate php
with lib; let
in {
  config = {
    programs = {
      khal = {
        enable = true;
        locale = {
          weeknumbers = "left";
          dateformat = "%d.%m.%Y";
          timeformat = "%H:%M";
        };
      };
      vdirsyncer.enable = true;
      todoman = {
        enable = true;
        glob = "*/*";
        extraConfig = ''
          date_format = "%d.%m.%Y"
          time_format = "%H:%M"
          default_list = "private"
          default_due = 48
          humanize = True
        '';
      };
    };

    services.vdirsyncer.enable = true;

    accounts.calendar = {
      basePath = ".local/share/calendar";
      accounts = {
        home = {
          primary = true;
          primaryCollection = "private";
          khal = {
            enable = true;
            type = "discover";
          };
          local = {
            type = "filesystem";
          };
          remote = {
            type = "caldav";
            url = "https://nextcloud.batfish-vibe.ts.net/remote.php/dav/calendars/mikilio/";
            userName = "mikilio";
            passwordCommand = ["cat" config.sops.secrets.nextcloud.path];
          };

          vdirsyncer = {
            enable = true;
            collections = ["private" "contact_birthdays"];
            conflictResolution = "remote wins";
          };
        };
      };
    };
  };
}
