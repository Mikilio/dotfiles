{
  inputs,
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  imports = [inputs.dms-plugin-registry.nixosModules.default];

  config =
    {
      services.displayManager.dms-greeter.enable = true;

      programs.dms-shell = {
        enable = true;
        package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        enableAudioWavelength = false;
        plugins = {
          dankBatteryAlerts.enable = true;
          dockerManager.enable = true;
        };
      };
    }
    // lib.optionalAttrs (options?home-manager) {
      services.displayManager = let
        users = builtins.attrNames config.home-manager.users;
        user =
          if (users != [])
          then builtins.head users
          else "";
      in
        lib.mkIf (users
          != []) {
          autoLogin = {
            enable = true;
            user = lib.mkDefault user;
          };
          dms-greeter = {
            enable = true;
            # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
            configHome = "/home/${user}";

            # Custom config files for non-standard config locations
            configFiles = [
              "/home/${user}/.config/DankMaterialShell/settings.json"
            ];
          };
        };
    };
}
