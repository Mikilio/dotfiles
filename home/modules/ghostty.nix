{
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) concatStringsSep attrNames readDir;
in {
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      initial-command = "${pkgs.tmux}/bin/tmux attach-session -t Desktop || bash
";
      command = "${pkgs.tmux}/bin/tmux attach-session -t Desktop";
      window-decoration = false;
      confirm-close-surface = false;

      #Linux
      gtk-single-instance = true;
      linux-cgroup = "single-instance";
    };
  };

  xdg = {
    enable = true;

    dataFile."xdg-terminals".source = "${pkgs.ghostty}/share/applications";

    configFile."xdg-terminals.list".text = (
      concatStringsSep "\n" (
        attrNames (
          lib.filterAttrs (entry: type: type == "regular") (readDir "${pkgs.ghostty}/share/applications")
        )
      )
    );
  };
  wayland.windowManager.hyprland.settings.exec-once = ["uwsm app ghostty"];
}
