{
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) concatStringsSep attrNames readDir;
in {
  programs.ghostty = {
    enable = true;
    settings = {
      command = ''
        ${pkgs.bashInteractive}/bin/bash -c '${lib.getExe pkgs.tmux} list-sessions >/dev/null 2>&1 && exec ${lib.getExe pkgs.tmux} attach-session -t Desktop || exec ${pkgs.bashInteractive}/bin/bash'
      '';
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
}
