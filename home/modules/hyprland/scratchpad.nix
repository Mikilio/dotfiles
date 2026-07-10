{
  lib,
  pkgs,
  config,
  ...
}: let
  wrap = cmds: lib.strings.concatStrings (lib.map (cmd: "uwsm app -- ${cmd} & ") cmds);

  getMatch = sp:
    if sp.match ? initialClass
    then {initial_class = sp.match.initialClass;}
    else {initial_title = sp.match.initialTitle;};

  matchType = lib.types.attrTag {
    initialClass = lib.mkOption {
      type = lib.types.str;
      description = "Initial class name for matching";
      example = "Morgen";
    };

    initialTitle = lib.mkOption {
      type = lib.types.str;
      description = "Initial title for matching";
      example = "Some App Title";
    };
  };

  scratchpad = {
    options = {
      command = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of commands to launch the application";
        example = [(lib.getExe pkgs.morgen)];
      };

      match = lib.mkOption {
        type = matchType;
        description = "Matching criteria (exactly one of initialClass or initialTitle as a tagged attr set)";
      };

      key = lib.mkOption {
        type = lib.types.str;
        description = "Keybinding character (e.g., 'A')";
        example = "A";
      };
    };
  };

  workspaceRule = name: sp: {
    workspace = "special:scratch_${name}";
    gaps_out = 60;
    layout = "scrolling";
    on_created_empty = lib.generators.mkLuaInline ''"${wrap sp.command}"'';
  };

  windowRule = name: sp: {
    workspace = "special:scratch_${name} silent";
    match = getMatch sp;
  };

  keybind = name: sp: {
    _args = [
      "SUPER + ${sp.key}"
      (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"scratch_${name}\")")
    ];
  };
in {
  options = {
    wayland.windowManager.hyprland.scratchpads = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule scratchpad);
      default = {};
      description = "Attribute set of scratchpad applications";
      example = lib.literalExpression ''
        {
          morgen = {
            command = [ (lib.getExe pkgs.morgen) ];
            match = {
              initialClass = "Morgen";
            };
            key = "A";
          };
          someTitleApp = {
            command = [ "some-app" ];
            match = {
              initialTitle = "Some Title";
            };
            key = "K";
          };
        }
      '';
    };
  };

  config = lib.mkIf (config.wayland.windowManager.hyprland.scratchpads != {}) {
    wayland.windowManager.hyprland.settings = {
      config.misc.initial_workspace_tracking = 0;

      window_rule = lib.mkAfter (
        lib.attrsets.mapAttrsToList windowRule config.wayland.windowManager.hyprland.scratchpads
        ++ [
          {
            match.float = false;
            match.workspace = "s[1]";
            rounding = 8;
          }
          {
            match.float = false;
            match.workspace = "s[1]";
            border_size = 3;
          }
        ]
      );

      workspace_rule = lib.mkAfter (lib.attrsets.mapAttrsToList workspaceRule config.wayland.windowManager.hyprland.scratchpads);

      bind = lib.attrsets.mapAttrsToList keybind config.wayland.windowManager.hyprland.scratchpads;
    };
  };
}
