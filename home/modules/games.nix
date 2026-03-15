{
  options,
  pkgs,
  lib,
  ...
}: {
  config = {
    home =
      {
        packages = let
          discordo = pkgs.writeShellScriptBin "discordo" ''
            export DISCORD_TOKEN=$(${lib.getExe pkgs.pass} show discord/token)
            exec ${lib.getExe pkgs.discordo} --token $DISCORD_TOKEN
          '';
        in [
          # discordo
          # pkgs.fjordlauncher
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/storage" = {
          directories = [
            {
              directory = ".steam";
              mode = "0755";
            }
          ];
        };
        persistence."/persistent/cache" = {
          directories = [
            {
              directory = ".local/share/Steam";
              mode = "0755";
            }
          ];
        };
      };
  };
}
