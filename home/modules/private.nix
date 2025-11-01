{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModule
  ];

  config = {
    sops = {
      # or some other source for the decryption key
      gnupg.home = "${config.xdg.dataHome}/gnupg";
      # or which file contains the encrypted secrets
      defaultSopsFile = ../../secrets/user/mikilio.yaml;
      secrets = {
        google-git = {};
        weather = {};
        github = {};
      };
    };
    systemd.user.services.sops-nix = {
      Install = {
        WantedBy = lib.mkForce ["graphical-session.target"];
      };
      Unit = {
        After = "graphical-session.target";
        Before = "xdg-desktop-autostart.target";
      };
    };

    home.username = lib.mkDefault "mikilio";
    home.homeDirectory = lib.mkDefault "/home/mikilio/";

    #NOTE: Private informations per module

    #NOTE: hyprland

    i18n.inputMethod.fcitx5.imList = ["keyboard-us" "keyboard-ua" "mozc"];
    programs.hyprpanel.settings.menus.powermenu.avatar.image = ../../assets/mikilio.png;
    programs.hyprlock.settings.image = [
      # USER AVATAR
      {
        path = "${../../assets/mikilio.png}";
        size = 200;
        position = "0, 250";
        halign = "center";
        valign = "center";
      }
    ];
    wayland.windowManager.hyprland = {
      settings.device = [
        {
          name = "at-translated-set-2-keyboard";
          kb_layout = "de,eu";
          kb_variant = ",eurkey-cmk-dh-iso";
        }
        {
          name = "semico---usb-gaming-keyboard-";
          kb_layout = "us";
        }
      ];
      scratchpads = {
        morgen = {
          command = [(lib.getExe pkgs.morgen)];
          match.initialClass = "Morgen";
          key = "A"; # Agenda
        };

        zotero = {
          command = [(lib.getExe pkgs.zotero)];
          match.initialClass = "Zotero";
          key = "R"; # Reading
        };

        slack = {
          command = [(lib.getExe pkgs.slack)];
          match.initialClass = "Slack";
          key = "S"; #Social | Slack
        };

        spotify = {
          command = [(lib.getExe pkgs.spotifywm)];
          match.initialClass = "spotify";
          key = "T"; # Tunes
        };

        chat = {
          command = [(lib.getExe pkgs.telegram-desktop) "${pkgs.whatsapp-for-linux}/bin/wasistlos"];
          match.initialClass = "org.telegram.desktop";
          key = "C"; # Chat
        };

        vesktop = {
          command = [(lib.getExe pkgs.vesktop)];
          match.initialClass = "vesktop";
          key = "D"; # Discord
        };

        teams = {
          command = [(lib.getExe pkgs.teams-for-linux)];
          match.initialClass = "temas-for-linux";
          key = "M"; # Microsoft Teams | Meetings
        };

        obsidian = {
          command = [(lib.getExe pkgs.obsidian)];
          match.initialClass = "obsidian";
          key = "N"; # Notes
        };

        element = {
          command = [(lib.getExe pkgs.element-desktop)];
          match.initialClass = "Element";
          key = "E"; #Element
        };

        thunderbird = {
          command = [(lib.getExe pkgs.thunderbird)];
          match.initialClass = "thunderbird";
          key = "I"; #Inbox
        };
      };
    };

    #NOTE: email

    accounts.email.accounts = {
      TUM = {
        address = "kilian.mio@tum.de";
        userName = "ga84tet@mytum.de";
        aliases = [];
        realName = "Kilian Mio";
        imap = {
          host = "xmail.mwn.de";
          port = 993;
        };
        smtp = {
          host = "postout.lrz.de";
          port = 465;
        };
        passwordCommand = "pass TUM/tum.de/ga84tet | head -n1";
        thunderbird.enable = true;
      };
      Duckrabbit = {
        address = "mikilio@duckrabbit.com";
        flavor = "outlook.office365.com";
        aliases = [];
        realName = "Kilian Mio";
        thunderbird = {
          enable = true;
          settings = id: {
            "mail.smtpserver.smtp_${id}.authMethod" = 10;
            "mail.server.server_${id}.authMethod" = 10;
          };
        };
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
            "mail.server.server_${id}.authMethod" = 10;
            "mail.identity.id_${id}.htmlSigFormat" = true;
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

    #NOTE: git
    programs = {
      git = {
        userName = "Mikilio";
        userEmail = "official.mikilio@gmail.com";
        signing = {
          signByDefault = true;
          format = "openpgp";
          key = "0C159FAB320FEB35!";
        };
        extraConfig = {
          sendemail = {
            smtpServer = "smtp.gmail.com";
            smtpServerPort = 587;
            smtpEncryption = "tls";
            smtpUser = "official.mikilio@gmail.com";
          };
          credential."smtp://smtp.gmail.com:587".helper = ''
            !f() { echo username=official.mikilio@gmail.com; echo "password=$(cat ${config.sops.secrets.google-git.path})"; }; f 2> /dev/null
          '';
        };
      };
      gh = {
        hosts = {
          "github.com" = {
            user = "Mikilio";
          };
        };
      };
    };

    #NOTE: gpg
    xdg.configFile."sops/age/keys.txt".text = ''
      #       Serial: 23674753, Slot: 1
      #         Name: Personal
      #      Created: Sun, 19 Oct 2025 15:22:21 +0000
      #   PIN policy: Once   (A PIN is required once per session, if set)
      # Touch policy: Always (A physical touch is required for every decryption)
      #    Recipient: age1yubikey1qfevylzne52c04dyhjwyyl5dpqz342kaqpm4eyzv7h04p40r48k9vayesv6
      AGE-PLUGIN-YUBIKEY-1SYLKJQVZ786A9JSDRSSMT
    '';

    pam.yubico.authorizedYubiKeys.ids = ["cccccbhkevjb"];

    services.gpg-agent.sshKeys = ["CC15ADE7A7DCCD12159E32BB32D14EFFEBE8EB5C"];

    programs.gpg.publicKeys = [
      #Yubikey
      {
        text = ''
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Comment: FB7D 6555 C6D5 73A5 4131  7C46 FFF9 4A59 8654 2148
          Comment: Mikilio  <official.mikilio@gmail.com>

          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
          =daN4
          -----END PGP PUBLIC KEY BLOCK-----
        '';
        trust = "ultimate";
      }
      # Pixel Phone
      {
        text = ''
          -----BEGIN PGP PUBLIC KEY BLOCK-----

          mDMEaDsWVRYJKwYBBAHaRw8BAQdApD3MHj/w9S9Jf7ReNqrbZTEn0c3SxO7YY56Y
          as77gba0NUtpbGlhbiBNaW8gKFBpeGVsIFBob25lKSA8b2ZmaWNpYWwubWlraWxp
          b0BnbWFpbC5jb20+iJQEExYKADwWIQRUFuE5m5/BAwXS1OiD6NwvCn7PYgUCaDsW
          VQIbAwUJBaOagAQLCQgHBBUKCQgFFgIDAQACHgUCF4AACgkQg+jcLwp+z2JUxAEA
          qkHWRopx9No8a4bHS8kq7pJqcCFJ3VL/1ebctDPqSPQA/iXbxUr37pRgRWr3zZYJ
          EUAZfLkV3WCsiyv1WgjjTO0PuDgEaDsWVRIKKwYBBAGXVQEFAQEHQHqk0EKIiJxe
          sz4yzMAl0PX/dyhI9swNwxERUlOdzDYvAwEIB4h+BBgWCgAmFiEEVBbhOZufwQMF
          0tTog+jcLwp+z2IFAmg7FlUCGwwFCQWjmoAACgkQg+jcLwp+z2Jn7AD/Xs03Wi/d
          jfouINFUXA7JIw4eWvyT0KsPdRzUlE0OB6UBAIRtFaqwOGdQ/a5nqZqIx6PX65Yl
          0ioE9nW4n7QsbY8B
          =X0C3
          -----END PGP PUBLIC KEY BLOCK-----
        '';
        trust = "ultimate";
      }
    ];
  };
}
