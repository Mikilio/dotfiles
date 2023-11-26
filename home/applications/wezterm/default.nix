{
  theme,
  pkgs,
  config,
  lib,
  ...
}:
with lib;
# terminals
  let
    cfg = config.preferences.apps.terminal;
  in {
    config = mkIf (cfg == "wezterm") {
      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;
        extraConfig = builtins.readFile ./wezterm.lua;
      };

      home.sessionVariables.TERM = "wezterm";
      xdg.configFile."autostart/org.wezfurlong.wezterm.desktop".source = "${config.programs.wezterm.package}/share/applications/org.wezfurlong.wezterm.desktop";
    };
  }
