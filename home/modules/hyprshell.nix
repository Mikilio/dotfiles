{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.hyprshell.homeManagerModules.default];
  programs.hyprshell = {
    enable = true;
    systemd = true;
    settings = let
      toggle = program: service: let
        prog = builtins.substring 0 14 program;
        runserv = lib.optionalString service "run-as-service";
      in "pkill ${prog} || ${runserv} ${program}";
    in {
      bar.battery.percentage = false;
      theme.dark.bg = "#${config.lib.stylix.colors.base00}";
      theme.dark.fg = "#${config.lib.stylix.colors.base05}";
      theme.dark.primary.bg = "#${config.lib.stylix.colors.base0E}";
      theme.dark.primary.fg = "#${config.lib.stylix.colors.base00}";
      theme.dark.error.bg = "#${config.lib.stylix.colors.base08}";
      theme.dark.error.fg = "#${config.lib.stylix.colors.base00}";
      theme.dark.widget = "#${config.lib.stylix.colors.base02}";
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
    exec-once = ["hyprshell -b hypr"];
    bind = let
      e = "exec, hyprshell -b hypr";
    in [
      "CTRL ALT, R, exec, systemctl --user restart hyprshell.service"
      #prefer anyrun
      # "SUPER, Space,  ${e} -t launcher"
      "SUPER, Escape, ${e} -t powermenu"
      "SUPER, Tab,    ${e} -t overview"

      ", F1, ${e} -r 'color.pick()'"
      ",Print, ${e} -r 'recorder.screenshot()'"
      "SHIFT,Print, ${e} -r 'recorder.screenshot(true)'"
    ];
  };
}
