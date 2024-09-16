{pkgs, ...}: {

  accounts.email.accounts = {
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
                <p>Best regards,</p>
                <p><strong>Kilian Mio</strong><br>
                Freelancer at Mikilio</p>
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
    Duckrabbit = {
      address = "mikilio@duckrabbit.com";
      flavor = "outlook.office365.com";
      gpg = {
        key = "FFF94A5986542148";
        signByDefault = true;
      };
      realName = "Kilian Mio";
      thunderbird = {
        enable = true;
        settings = id: {
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPolicies.ExtensionSettings = {
        "{16b73c21-a2ff-46c4-8b5f-eb0c7d115db7}" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.thunderbird.net/user-media/addons/988699/thunderai_chatgpt_in_your_emails-1.2.1-tb.xpi?filehash=sha256%3A0a51429e6f4da77eae4f083c2ff9419b48270b57f0505a5f0b736db731139a98";
        };
      };
    };
    settings = {
      "mail.biff.show_tray_icon_always" = true;
      "mail.minimizeToTray" = true;
      "ldap_2.servers.outlook.dirType" = 3;
    };
    profiles = {
      default = {
        isDefault = true;
        withExternalGnupg = true;
      };
    };
  };
}
