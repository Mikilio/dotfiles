{
  pkgs,
  lib,
  config,
  ...
}: let
  nativeHosts = with pkgs; [
    tridactyl-native
    browserpass
  ];
in {
  config = {
    stylix.targets.floorp = {
      profileNames = ["Default" "PWA"];
      colorTheme.enable = true;
    };
    programs.floorp = {
      enable = true;
      nativeMessagingHosts = nativeHosts;
      profiles = {
        Default = {
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
          extensions = {
            force = true;
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              stylus
              browserpass
              languagetool
              sidebery
              skip-redirect
              # firemonkey
              wikiwand-wikipedia-modernized
              zotero-connector
              # bypass-paywalls-clean
              metamask
            ];
          };
        };
        PWA = {
          id = 1;
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
          extensions = {
            force = true;
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
            ];
          };
        };
      };
    };

    xdg.configFile = {
      "firejail/floorp.local".text = "include firefox-common-addons.profile";
      "tridactyl/tridactylrc".source = ./tridactylrc;
      "tridactyl/themes/stylix.css".text = with config.lib.stylix.colors.withHashtag;
        ''
          :root {
              --base00: ${base00};
              --base01: ${base01};
              --base02: ${base02};
              --base03: ${base03};
              --base04: ${base04};
              --base05: ${base05};
              --base06: ${base06};
              --base07: ${base07};
              --base08: ${base08};
              --base09: ${base09};
              --base0A: ${base0A};
              --base0B: ${base0B};
              --base0C: ${base0C};
              --base0D: ${base0D};
              --base0E: ${base0E};
              --base0F: ${base0F};
          }
        ''
        + builtins.readFile ./base16.css;
    };
  };
}
