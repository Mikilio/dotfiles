{
  lib,
  pkgs,
  config,
  ...
}: let
  wrap = cmds: lib.strings.concatStrings (lib.map (cmd: "uwsm app -- ${cmd} & ") cmds);

  getMatch = sp:
    if sp.match ? initialClass
    then "initialClass:${sp.match.initialClass}"
    else "initialTitle:${sp.match.initialTitle}";

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

  workspaceRule = name: sp: "special:scratch_${name},shadow:1, gapsout:60, on-created-empty:${wrap sp.command}";

  windowRule = name: sp: "workspace special:scratch_${name} silent, ${getMatch sp}";

  keybind = name: sp: "SUPER, ${sp.key}, togglespecialworkspace, scratch_${name}";
in {
  options = {
    # Replace 'my' with your preferred module namespace, e.g., programs.hyprland.scratchApps
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
      misc.initial_workspace_tracking = 0;

      windowrulev2 = lib.mkAfter (
        lib.attrsets.mapAttrsToList windowRule config.wayland.windowManager.hyprland.scratchpads
        ++ [
          "rounding 8, floating:0, onworkspace:s[1]"
          "bordersize 3, floating:0, onworkspace:s[1]"
        ]
      );

      workspace = lib.mkAfter (lib.attrsets.mapAttrsToList workspaceRule config.wayland.windowManager.hyprland.scratchpads);

      bind = lib.attrsets.mapAttrsToList keybind config.wayland.windowManager.hyprland.scratchpads;
    };
  };
}
