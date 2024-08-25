{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.kaizen.homeManagerModules.default];
  programs.kaizen = {
    enable = true;
    systemd = true;
    settings = let
      toggle = program: service: let
        prog = builtins.substring 0 14 program;
        runserv = lib.optionalString service "run-as-service";
      in "pkill ${prog} || ${runserv} ${program}";
    in {
      run.execCmd = "hyprctl dispatch exec -- '${toggle "anyrun" true}'";
      bar.battery.percentage = false;
      theme.dark.bg = "#${config.lib.stylix.colors.base00}";
      theme.dark.fg = "#${config.lib.stylix.colors.base05}";
      theme.dark.primary.bg = "#${config.lib.stylix.colors.base0E}";
      theme.dark.primary.fg = "#${config.lib.stylix.colors.base00}";
      theme.dark.error.bg = "#${config.lib.stylix.colors.base08}";
      theme.dark.error.fg = "#${config.lib.stylix.colors.base00}";
      theme.dark.widget = "#${config.lib.stylix.colors.base07}";
      theme.dark.border = "#${config.lib.stylix.colors.base0E}";
      theme.radius = 4;
      theme.border.width = 2;
      theme.widget.opacity = 69;
      theme.spacing = 11;
      workspaces.scale = 8;
      hyprland.shader = "default";
      font.default.name = "DejaVu Sans Bold Oblique";
      font.default.size = 10;
    };
  };

  wayland.windowManager.hyprland.settings = {
    bind = [
      "CTRL ALT, R, exec, systemctl --user restart kaizen.service"
    ];
  };
}
