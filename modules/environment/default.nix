{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.environment;
  profiles = with builtins;
    concatLists (
    filter (e: e!=null && e!=["default"]) (
    map (x: match "(.+).nix" x) (
    attrNames (
    readDir(./.)
  ))));
in {
  options.modules.environment = {
    profile = mkOption {
      example = builtins.head profiles;
      description = ''
        Profiles for user-environments. Each profile provides functionality
        equivalent to a proper desktop environment. This includes a
        window-manager, environment-variables and themes. Available profiles
      '';
      type = let
        profile = mkOptionType {
          name = "Environment Profile";
          check = (p: builtins.elem p profiles);
        };
        in types.uniq profile;
    };
  };

  imports = builtins.map (profile: ./${profile}.nix) profiles;

  config = {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      documents = "${config.home.homeDirectory}/docs";
      download = "${config.home.homeDirectory}/etc/private";
      music = "${config.home.homeDirectory}/media/music";
      pictures = "${config.home.homeDirectory}/media/pics";
      videos = "${config.home.homeDirectory}/media/videos";
      publicShare = "${config.home.homeDirectory}/etc/public";
      templates = "${config.home.homeDirectory}/temp";
      extraConfig = {
        XDG_DEV_DIR = "${config.home.homeDirectory}/dev";
        XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
      };
    };
  };
}
