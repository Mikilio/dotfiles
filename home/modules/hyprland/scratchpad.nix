{
  lib,
  pkgs,
  ...
}:
let

  wrap = cmds: lib.strings.concatStrings (lib.map (cmd: "uwsm app -- ${cmd} & ") cmds);
  apps = {

    morgen = {
      command = [ (lib.getExe pkgs.morgen) ];
      match_by = "initialClass";
      initialClass = "Morgen";
      size = "80% 80%";
      key = "A"; # Agenda
    };

    zotero = {
      command = [ (lib.getExe pkgs.zotero) ];
      match_by = "initialClass";
      initialClass = "Zotero";
      size = "90% 90%";
      key = "R"; # Reading
    };

    slack = {
      command = [ (lib.getExe pkgs.slack) ];
      match_by = "initialClass";
      initialClass = "Slack";
      size = "80% 80%";
      key = "S"; #Social | Slack
    };

    spotify = {
      command = [ (lib.getExe pkgs.spotifywm) ];
      match_by = "initialClass";
      initialClass = "spotify";
      size = "80% 80%";
      key = "T"; # Tunes
    };

    chat = {
      command = [ (lib.getExe pkgs.telegram-desktop) "${pkgs.whatsapp-for-linux}/bin/wasistlos" ];
      match_by = "initialClass";
      initialClass = "org.telegram.desktop";
      size = "50% 90%";
      key = "C"; # Chat
    };

    vesktop = {
      command = [ (lib.getExe pkgs.vesktop) ];
      match_by = "initialClass";
      initialClass = "vesktop";
      size = "80% 80%";
      key = "D"; # Discord
    };

    teams = {
      command = [ (lib.getExe pkgs.teams-for-linux)];
      match_by = "initialClass";
      initialClass = "temas-for-linux";
      size = "80% 80%";
      key = "M"; # Microsoft Teams | Meetings
    };

    obsidian = {
      command = [ (lib.getExe pkgs.obsidian) ];
      match_by = "initialClass";
      initialClass = "obsidian";
      size = "90% 90%";
      key = "N"; # Notes
    };

    element = {
      command = [ (lib.getExe pkgs.element-desktop) ];
      match_by = "initialClass";
      initialClass = "Element";
      size = "80% 80%";
      key = "E"; #Element
    };

    thunderbird = {
      command = [ (lib.getExe pkgs.thunderbird-latest) ];
      match_by = "initialClass";
      initialClass = "thunderbird";
      size = "90% 90%";
      key = "I"; #Inbox
    };
  };
  workspaceRule = name: app: "special:scratch_${name},shadow:1, gapsout:60, on-created-empty:${wrap app.command}";
  windowRule =
    name: app: "workspace special:scratch_${name} silent, ${app.match_by}:${app.${app.match_by}}";
  keybind = name: app: "SUPER, ${app.key}, togglespecialworkspace, scratch_${name}";

in
{
  wayland.windowManager.hyprland.settings = {
    misc.initial_workspace_tracking = 0;
    windowrulev2 = lib.mkAfter (
      lib.attrsets.mapAttrsToList windowRule apps
      ++ [
        "rounding 8, floating:0, onworkspace:s[1]"
        "bordersize 3, floating:0, onworkspace:s[1]"
      ]
    );
    workspace = lib.mkAfter (lib.attrsets.mapAttrsToList workspaceRule apps);
    bind = lib.attrsets.mapAttrsToList keybind apps;
  };
}
