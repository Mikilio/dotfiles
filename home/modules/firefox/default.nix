{
  pkgs,
  ...
}: let
  autoConfig = builtins.readFile ./autoconfig.js;
in {
  config = {
    programs.firefox = {
      enable = true;
      # package = pkgs.firefox.override (old: {
      #   extraPrefsFiles =
      #     old.extraPrefsFiles or []
      #     ++ [(pkgs.writeText "firefox-autoconfig.js" autoConfig)];
      # });
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
        browserpass
      ];
      profiles.Default = {
        extraConfig = builtins.readFile ./user.js;
        userChrome = builtins.readFile ./userChrome.css;
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          tridactyl
          ublock-origin
          stylus
          firefox-color
          browserpass
          languagetool
          sidebery
          skip-redirect
          # firemonkey
          tampermonkey
          wikiwand-wikipedia-modernized
          omnivore
          zotero-connector
          # bypass-paywalls-clean
        ];
      };
    };
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
