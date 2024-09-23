{
  config,
  pkgs,
  lib,
  ...
}:
let
  pyprlandConfig = {
    pyprland.plugins = [ "scratchpads" ];
    scratchpads = {
      vesktop = {
        command = "vesktop";
        match_by = "initialTitle";
        initialTitle = "Discord";
        animation = "fromBottom";
        position = "10% 10%";
        size = "80% 80%";
        allow_special_workspaces = true;
        unfocus = "hide";
        lazy = true;
      };
      spotify = {
        command = "spotify";
        match_by = "initialTitle";
        initialTitle = "Spotify Premium";
        animation = "fromBottom";
        position = "10% 10%";
        size = "80% 80%";
        allow_special_workspaces = true;
        unfocus = "hide";
      };
      logseq = {
        command = "logseq";
        match_by = "initialClass";
        initialClass = "Logseq";
        animation = "fromTop";
        position = "5% 5%";
        size = "90% 90%";
        excludes = "*";
        restore_excluded = false;
        allow_special_workspaces = true;
      };

      telegram = {
        command = "telegram-desktop";
        match_by = "initialClass";
        initialClass = "org.telegram.desktop";
        animation = "fromRight";
        size = "40% 90%";
        allow_special_workspaces = true;
      };
    };
  };
  makeRule = app: "float, ${app.match_by}:${app.${app.match_by}}";
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [ "${pkgs.pyprland}/bin/pypr" ];
    windowrulev2 = lib.attrsets.mapAttrsToList (_: makeRule) pyprlandConfig.scratchpads;
    bind =
      let
        e = "exec, pypr toggle";
      in
      [
        "SUPER, D, ${e} vesktop"
        "SUPER, S, ${e} spotify"
        "SUPER, L, ${e} logseq"
        "SUPER, T, ${e} telegram"
        "SUPER, X, exec, pypr hide \"*\""
      ];
  };
  home.packages = [ pkgs.pyprland ];

  xdg.configFile."hypr/pyprland.toml".source =
    (pkgs.formats.toml { }).generate "pyprland.toml"
      pyprlandConfig;

  systemd.user.services.pyprland = {
    Unit = {
      Description = "Scratchpads & many goodies for Hyprland";
      Documentation = "https://github.com/hyprland-community/pyprland";
      PartOf = [ "graphical-session.target" ];
      After = [ "xdg-desktop-autostart.target" ];
      X-Restart-Triggers = [
        "${config.xdg.configFile."hypr/pyprland.toml".source}"
      ];
    };

    Service =
      let
        pypr = "${pkgs.pyprland}/bin/pypr";
      in
      {
        ExecStart = pypr;
        ExecReload = "${pypr} reload";
        ExecStop = "${pypr} exit";
        Restart = "on-failure";
        #NOTE: not recommended but seems like the best solution now
        KillMode = "none";
      };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
