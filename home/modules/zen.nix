{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  xdg.mimeApps = let
    associations = builtins.listToAttrs (map (name: {
        inherit name;
        value = let
          zen-browser = config.programs.zen-browser.package;
        in
          zen-browser.meta.desktopFileName;
      }) [
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-html"
        "application/x-extension-xht"
        "application/x-extension-htm"
        "x-scheme-handler/unknown"
        # "x-scheme-handler/mailto"
        "x-scheme-handler/chrome"
        "x-scheme-handler/about"
        "x-scheme-handler/https"
        "x-scheme-handler/http"
        "application/xhtml+xml"
        "application/json"
        # "text/plain"
        "text/html"
      ]);
  in {
    associations.added = associations;
    defaultApplications = associations;
  };

  stylix.targets.zen-browser.profileNames = ["default"];

  programs.zen-browser = {
    enable = true;

    policies = let
      mkLockedAttrs = builtins.mapAttrs (_: value: {
        Value = value;
        Status = "locked";
      });
    in {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true; # save webs for later reading
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      Preferences = mkLockedAttrs {
        "browser.aboutConfig.showWarning" = false;
        "browser.tabs.warnOnClose" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
        # Disable swipe gestures (Browser:BackOrBackDuplicate, Browser:ForwardOrForwardDuplicate)
        "browser.gesture.swipe.left" = "";
        "browser.gesture.swipe.right" = "";
        "browser.tabs.hoverPreview.enabled" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.topsites.contile.enabled" = false;

        "privacy.resistFingerprinting" = true;
        "privacy.firstparty.isolate" = true;
        "network.cookie.cookieBehavior" = 5;
        "dom.battery.enabled" = false;

        "gfx.webrender.all" = true;
        "network.http.http3.enabled" = true;
      };
    };

    languagePacks = [
      "en-GB"
      "de"
      "pt-BR"
      "ja"
    ];

    profiles.default = rec {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.workspaces.force-container-workspace" = true;
        "zen.view.use-single-toolbar" = false;
        "zen.view.experimental-no-window-controls" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.toolbar-flash-popup" = true;
        "zen.view.compact.enable-at-startup" = true;
        "zen.welcome-screen.seen" = true;
      };

      userChrome = lib.mkForce "";

      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          stylus
          languagetool
          wikiwand-wikipedia-modernized
          zotero-connector
          return-youtube-dislikes
          clearurls
          steam-database
          decentraleyes
          metamask
          bitwarden
        ];
        # settings = {
        #   "uBlock0@raymondhill.net".settings = {
        #     default_area = "navbar";
        #   };
        #   "zotero@chnm.gmu.edu".settings = {
        #     default_area = "navbar";
        #   };
        #   "webextension@metamask.io".settings = {
        #     default_area = "navbar";
        #   };
        #
        #   # required for Stylus
        #   "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".settings = {
        #     dbInChromeStorage = true;
        #   };
        # };
      };

      # pinsForce = true;
      # pins = {
      #   "GitHub" = {
      #     id = "5d7b65e6-dabc-414e-b464-cb7c5f9193b7";
      #     workspace = spaces."R&D".id;
      #     url = "https://github.com";
      #     position = 101;
      #     isEssential = true;
      #   };
      #   "Hetzner" = {
      #     id = "11ab3ddb-3208-435a-b61e-93a901156cc6";
      #     workspace = spaces."R&D".id;
      #     url = "https://console.hetzner.cloud/";
      #     position = 102;
      #     isEssential = true;
      #   };
      #   "Tailscale" = {
      #     id = "567c89f0-4c8e-4891-ac33-e50006bd1c63";
      #     workspace = spaces."R&D".id;
      #     url = "https://login.tailscale.com/admin/machines";
      #     position = 103;
      #     isEssential = true;
      #   };
      #   "Odoo.sh" = {
      #     id = "7f888b49-f584-4332-8042-0e8f03c8e4a7";
      #     workspace = spaces."Work".id;
      #     url = "https://www.odoo.sh/";
      #     position = 104;
      #     isEssential = true;
      #   };
      # };

      containersForce = true;
      containers = {
        WorkAccounts = {
          color = "blue";
          icon = "briefcase";
          id = 1;
        };
        Shopping = {
          color = "yellow";
          icon = "dollar";
          id = 2;
        };
        Fun = {
          color = "purple";
          icon = "chill";
          id = 3;
        };
      };

      spacesForce = true;
      spaces = let
        base00 = {
          blue = 46;
          green = 30;
          red = 30;
        };
      in {
        "Work" = {
          id = "e829a486-6281-4a23-9f08-1069bf04a2dd";
          icon = "💼";
          position = 1000;
          container = containers."WorkAccounts".id;
          theme = {
            type = "gradient";
            colors = [
              base00
              {
                blue = 250;
                green = 180;
                red = 137;
              }
              {
                blue = 175;
                green = 226;
                red = 249;
              }
            ];
          };
        };
        "R&D" = {
          id = "128b19b1-be0a-4fbc-9f84-3f6871f123ac";
          icon = "🔬";
          position = 1001;
          theme = {
            type = "gradient";
            colors = [
              base00
              {
                blue = 247;
                green = 166;
                red = 203;
              }
              {
                blue = 250;
                green = 180;
                red = 137;
              }
            ];
          };
        };
        "Fun" = {
          id = "e3abe55c-b699-4d22-a349-e6902bb44741";
          icon = "🎉";
          position = 1002;
          container = containers."Fun".id;
          theme = {
            type = "gradient";
            colors = [
              base00
              {
                blue = 161;
                green = 227;
                red = 166;
              }
              {
                blue = 168;
                green = 139;
                red = 243;
              }
            ];
          };
        };
      };

      search = {
        force = true;
        default = "google";
        engines = let
          nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        in {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["np"];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["nop"];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "master"; # unstable
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["hmop"];
          };
          bing.metaData.hidden = "true";
        };
      };
    };
  };
}
