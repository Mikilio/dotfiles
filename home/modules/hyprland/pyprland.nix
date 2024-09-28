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
  floatRule = app: "float, ${app.match_by}:${app.${app.match_by}}";
  wkpRule = name: app: "workspace silent special:scratch_${name}, ${app.match_by}:${app.${app.match_by}}";
in
{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = lib.attrsets.mapAttrsToList (_: floatRule) pyprlandConfig.scratchpads
      ++ lib.attrsets.mapAttrsToList wkpRule pyprlandConfig.scratchpads;
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
      Requires = [ "sops-nix.service"];
      After = [ "xdg-desktop-autostart.target" "sops-nix.service"];
      X-Reload-Triggers = [
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
        ExecStopPost = "${pkgs.writeShellScript "cleanup" ''
          rm -f ''${XDG_RUNTIME_DIR}/hypr/''${HYPRLAND_INSTANCE_SIGNATURE}/.pyprland.sock
        ''}";
        Restart = "on-failure";
        KillMode = "control-group";
      };

    Install = {
      WantedBy = [ "xdg-desktop-autostart.target" ];
    };
  };
}
