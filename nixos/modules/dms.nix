{inputs, pkgs, ...}: {
  imports = [inputs.dms-plugin-registry.modules.default];

  config = {
    services.displayManager.dms-greeter = {
      enable = true;
      compositor = {
        name = "hyprland";
        customConfig = ''
          env = DMS_RUN_GREETER,1

          misc {
              disable_hyprland_logo = true
          }
        '';
      };
    };

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
  };
}
