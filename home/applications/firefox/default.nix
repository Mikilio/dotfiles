{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
in {
  config = /* mkIf (cfg != null && cfg.browser == "firefox") */ {
    programs.firefox = {
      enable = true;
      profiles.Default = {
        extraConfig = builtins.readFile ./user.js;
        userChrome = builtins.readFile ./userChrome.css;
        extensions = with config.nur.repos.rycee.firefox-addons; [
          ublock-origin
          stylus
          keepassxc-browser
          vimium
          languagetool
          sidebery
          skip-redirect
          unpaywall
        ];
      };
    };
    home.file.".mozilla/firefox/Default/chrome/includes" = {
      recursive = true;
      source = ./includes;
    };
  };
}
