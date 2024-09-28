{
  config,
  pkgs,
  ...
}:
let
  nativeHosts = with pkgs; [
    tridactyl-native
    browserpass
  ];

in
{
  config = {
    programs.floorp = {
      enable = true;
      vendorPath = ".floorp";
      nativeMessagingHosts = nativeHosts;
      profiles = {
        Default = {
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
          extensions = with config.nur.repos.rycee.firefox-addons; [
            tridactyl
            ublock-origin
            stylus
            browserpass
            firenvim
            languagetool
            sidebery
            skip-redirect
            # firemonkey
            tampermonkey
            wikiwand-wikipedia-modernized
            zotero-connector
            # bypass-paywalls-clean
            metamask
          ];
        };
        PWA = {
          id = 1;
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
          extensions = with config.nur.repos.rycee.firefox-addons; [
            ublock-origin
          ];
        };
      };
    };

    home.packages = nativeHosts;
    # xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
