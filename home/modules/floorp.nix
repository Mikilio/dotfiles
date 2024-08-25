{
  config,
  pkgs,
  ...
}: let 
  nativeHosts = with pkgs; [
    tridactyl-native
    browserpass
  ];

in {
  config = {
    programs.floorp = {
      enable = true;
      vendorPath = ".floorp";
      nativeMessagingHosts = nativeHosts;
      profiles.Default = {
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
        extensions = with config.nur.repos.rycee.firefox-addons; [
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
          metamask
        ];
      };
    };

    home.packages = nativeHosts;
    # xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
