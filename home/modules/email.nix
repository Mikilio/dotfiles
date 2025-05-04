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
  accounts.email.accounts = {
    TUM = {
      address = "kilian.mio@tum.de";
      userName = "ga84tet@mytum.de";
      aliases = [];
      gpg = {
        key = "FFF94A5986542148";
        signByDefault = true;
      };
      realName = "Kilian Mio";
      imap = {
        host = "xmail.mwn.de";
        port = 993;
      };
      smtp = {
        host = "postout.lrz.de";
        port = 465;
      };
      passwordCommand = "pass TUM/online";
      thunderbird.enable = true;
    };
    Google = {
      primary = true;
      address = "official.mikilio@gmail.com";
      flavor = "gmail.com";
      gpg = {
        key = "FFF94A5986542148";
        signByDefault = true;
      };
      realName = "Kilian Mio";
      thunderbird = {
        enable = true;
        settings = id: {
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
          "mail.identity.id_${id}.htmlSigText" = ''
            <div style="font-family: Arial, sans-serif; padding: 10px;">
              <style>
                @media (prefers-color-scheme: dark) {
                  .signature {
                    color: #fff;
                  }
                  .signature a {
                    color: #CBA6F7;
                  }
                }
                @media (prefers-color-scheme: light) {
                  .signature {
                    color: #333;
                  }
                  .signature a {
                    color: #8839EF;
                  }
                }
              </style>
              <div class="signature">
                <p><strong>Kilian Mio</strong><br>
                Mikilio</p>
              </div>
              <div class="signature" style="padding: 10px; border: 1px solid #CBA6F7; border-radius: 5px;">
                <p><strong>Address:</strong><br>
                Einsteinstraße 10<br>
                85748 Garching bei München<br>
                Munich, Germany</p>
                <p><strong>Phone:</strong> <a href="tel:+4915153270276">+49 151 53270276</a><br>
                <strong>Email:</strong> <a href="mailto:official.mikilio@gmail.com">official.mikilio@gmail.com</a></p>
                <p><strong>VAT Number:</strong> DE368859881</p>
              </div>
            </div>
          '';
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird-latest;
    settings = {
      "extensions.autoDisableScopes" = 0;
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
