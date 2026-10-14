{
  inputs,
  config,
  options,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config =
    {
      xdg.mimeApps = let
        associations = builtins.listToAttrs (map (name: {
            inherit name;
            value = "zen-beta.desktop";
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

      warnings =
        lib.optional (
          config.programs.zen-browser.profiles.default.containers
          == {}
          && config.programs.zen-browser.profiles.default.spaces == {}
        ) ''
          No Zen Browser containers or spaces are declared, so the browser starts
          with a stock setup. Declaring them in your profile is recommended for
          the full experience.
        '';

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        nativeMessagingHosts = [];
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

        profiles.default = {
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
    // lib.optionalAttrs (builtins.hasAttr "stylix" options)
    {
      stylix.targets.zen-browser = {
        profileNames = ["default"];
        enableCss = false;
      };
    }
    // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
    {
      home.persistence."/persistent/storage" = {
        directories = [
          {
            directory = ".config/zen";
            mode = "0700";
          }
        ];
      };
    };
}
