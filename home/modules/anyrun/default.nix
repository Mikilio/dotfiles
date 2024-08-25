{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  programs.anyrun = {
    enable = true;

    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        # randr
        rink
        shell
        symbols
      ];

      width.fraction = 0.25;
      y.fraction = 0.25;
      hidePluginInfo = true;
      closeOnClick = true;
    };

    extraCss = builtins.readFile (./. + "/style-dark.css");

    extraConfigFiles = {
      "applications.ron".text = ''
        Config(
          desktop_actions: false,
          max_entries: 5,
          terminal: Some("foot"),
        )
      '';

      "shell.ron".text = ''
        Config(
          prefix: ">"
        )
      '';
    };
  };

  wayland.windowManager.hyprland.settings = let
    toggle = program: service: let
      prog = builtins.substring 0 14 program;
      runserv = lib.optionalString service "run-as-service";
    in "pkill ${prog} || ${runserv} ${program}";
  in {
    bindr = [
      "$mod, SPACE, exec, ${toggle "anyrun" true}"
    ];
  };
}
