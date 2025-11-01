{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
  extensions = [
    (pkgs.fetchFirefoxAddon {
      name = "thunderAI";
      src = inputs.thunderAI;
    })
    # (pkgs.fetchFirefoxAddon {
    #   name = "language-tool";
    #   src = inputs.language-tool;
    # })
    # (pkgs.fetchFirefoxAddon {
    #   name = "tbConversations ";
    #   src = inputs.tbConversations;
    # })
  ];
in {
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird;
    settings = {
      "extensions.autoDisableScopes" = 0;
      "mail.identity.default.reply_on_top" = 1;
      "mail.biff.show_tray_icon_always" = true;
      "mail.minimizeToTray" = true;
      "ldap_2.servers.outlook.dirType" = 3;
      "dom.security.unexpected_system_load_telemetry_enabled" = false;
      "network.trr.confirmation_telemetry_enabled" = false;
      "privacy.trackingprotection.origin_telemetry.enabled" = false;
      "telemetry.origin_telemetry_test_mode.enabled" = false;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.ecosystemtelemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabledFirstSession" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.prompted" = 2;
    };
    profiles = {
      default = {
        isDefault = true;
        withExternalGnupg = true;
      };
    };
  };

  home.file = {
    ".thunderbird/default/extensions" = {
      source =
        (pkgs.buildEnv {
          name = "hm-thunderbird-extensions";
          paths = extensions;
        }).outPath;
      recursive = true;
      force = true;
    };
  };
}
