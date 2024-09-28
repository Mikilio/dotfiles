{
  lib,
  pkgs,
  ...
}:
let
  apps = {
    vesktop = {
      command = lib.getExe pkgs.vesktop;
      match_by = "initialTitle";
      initialTitle = "Discord";
      size = "80% 80%";
      key = "S"; # Social
    };
    spotify = {
      command = lib.getExe pkgs.spotifywm;
      match_by = "initialTitle";
      initialTitle = "Spotify Premium";
      size = "80% 80%";
      key = "M"; # Music
    };
    logseq = {
      command = lib.getExe pkgs.logseq;
      match_by = "initialClass";
      initialClass = "Logseq";
      size = "90% 90%";
      key = "N"; # Notes
    };

    telegram = {
      command = lib.getExe pkgs.telegram-desktop;
      match_by = "initialClass";
      initialClass = "org.telegram.desktop";
      size = "40% 90%";
      key = "T"; # Telegram
    };

    zotero = {
      command = lib.getExe pkgs.zotero;
      match_by = "initialClass";
      initialClass = "Zotero";
      size = "40% 90%";
      key = "A"; # Academia
    };

    sioyek = {
      command = lib.getExe pkgs.sioyek;
      match_by = "initialClass";
      initialClass = "Zotero";
      size = "40% 90%";
      key = "R"; # Reading
    };
  };
  workspaceRule = name: app: "special:scratch_${name},shadow:1, gapsout:60, on-created-empty:${app.command}";
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
