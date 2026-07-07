{ pkgs, lib, config, ... }:
let
  inherit (builtins) concatStringsSep attrNames readDir;
in
{
  home.sessionVariables.TERM = "foot";

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        shell = "${lib.getExe pkgs.tmux} list-sessions >/dev/null 2>&1 && ${lib.getExe pkgs.tmux} attach-session || exec ${pkgs.bashInteractive}/bin/bash";
        login-shell = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3;
      };

      url = {
        launch = "xdg-open \${url}";
        label-letters = "sadfjklewcmpgh";
        osc8-underline = "url-mode";
        protocols = "http, https, ftp, ftps, file";
        uri-characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.,~:;/?#@!$&%*+=\"'()[]";
      };

      cursor = {
        style = "beam";
        beam-thickness = 1;
      };
    };
  };

  xdg = {
    enable = true;

    dataFile."xdg-terminals".source = "${pkgs.foot}/share/applications";

    configFile."xdg-terminals.list".text = (
      concatStringsSep "\n" (
        attrNames (
          lib.filterAttrs (entry: type: type == "regular") (readDir "${pkgs.foot}/share/applications")
        )
      )
    );
  };
}
