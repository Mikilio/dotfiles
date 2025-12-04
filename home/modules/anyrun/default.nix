{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.anyrun = {
    enable = true;

    config = {
      plugins = [
        inputs.anyrun-rbw.packages.${pkgs.system}.default
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libnix_run.so"
      ];

      width.fraction = 0.3;
      x.fraction = 0.5;
      y.fraction = 0.25;
      closeOnClick = true;
      maxEntries = 12;
    };

    extraCss = builtins.readFile (./. + "/style.css");

    extraConfigFiles = {
      "applications.ron".text = ''
        Config(
          desktop_actions: true,
          max_entries: 5,
          terminal: Some(Terminal(
            command: "ghostty",
            args: "--title=ephemeral -e {}",
          )),
        )
      '';

      "translate.ron".text = ''
        Config(
          prefix: ":",
          language_delimiter: ">",
          max_entries: 3,
        )
      '';

      "nix-run.ron".text = ''
        Config(
          prefix: ":nr ",
          allow_unfree: true,
          channel: "nixpkgs-unstable",
          max_entries: 3,
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
    layerrule = [
      "blur, anyrun"
      "ignorealpha 0.5, anyrun"
      "animation fade, anyrun"
    ];
  };
}
