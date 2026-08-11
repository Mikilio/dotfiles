{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  inherit (builtins) concatStringsSep attrNames readDir;

  tmux = lib.getExe pkgs.tmux;
  tmuxCommand = ''
    ${pkgs.bashInteractive}/bin/bash -c '${tmux} list-sessions >/dev/null 2>&1 && exec ${tmux} attach-session -t Desktop || exec ${pkgs.bashInteractive}/bin/bash'
  '';

  herdrEnabled = builtins.hasAttr "herdr" options.programs && config.programs.herdr.enable;
in {
  programs.ghostty = {
    enable = true;
    settings = {
      command = lib.mkIf (config.programs.tmux.enable || herdrEnabled) (
        if config.programs.tmux.enable
        then tmuxCommand
        else lib.getExe pkgs.herdr
      );
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
