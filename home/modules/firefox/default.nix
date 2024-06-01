{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  autoConfig = builtins.readFile ./autoconfig.js;
in {
  config = {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override (old: {
        extraPrefsFiles =
          old.extraPrefsFiles
          or []
          ++ [(pkgs.writeText "firefox-autoconfig.js" autoConfig)];
        nativeMessagingHosts = [pkgs.tridactyl-native];
      });
      profiles.Default = {
        extraConfig = builtins.readFile ./user.js;
        extensions = with config.nur.repos.rycee.firefox-addons; [
          tridactyl
          ublock-origin
          stylus
          firefox-color
          keepassxc-browser
          languagetool
          sidebery
          skip-redirect
          unpaywall
          # firemonkey
          tampermonkey
          wikiwand-wikipedia-modernized
        ];
      };
    };
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
  };
}
