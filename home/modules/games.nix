{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

lib.optionalAttrs osConfig.programs.steam.enable {
  home.packages =
    let
      discordo = pkgs.writeShellScriptBin "discordo" ''
        export DISCORD_TOKEN=$(${lib.getExe pkgs.pass} show discord/token)
        exec ${lib.getExe pkgs.discordo} --token $DISCORD_TOKEN
      '';
    in
    [
      discordo
      pkgs.fjordlauncher
    ];

}
