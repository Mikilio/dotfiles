{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.home.shells.starship;
in {
  config = mkIf cfg {
    home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

    programs.starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[›](bold green)";
          error_symbol = "[›](bold red)";
        };

        git_status = {
          deleted = "✗";
          modified = "✶";
          staged = "✓";
          stashed = "≡";
        };

        nix_shell = {
          symbol = " ";
          heuristic = true;
        };
      };
    };
  };
}
