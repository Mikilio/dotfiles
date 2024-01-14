{ config
, pkgs
, lib
, ...
}:

with lib;

let

  cfg = config.preferences.cli.shell;

in mkIf (!isNull cfg) {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unar
    unrar-wrapper

    #TUI
    calcurse

    # utils
    jaq
    file
    du-dust
    duf
    fd
    bat
    ripgrep
    xdg-utils
    config.nur.repos.mikilio.xdg-terminal-exec
  ];

  programs = {

    zoxide.enable = true;

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Catppuccin-mocha";
      };
      themes = {
        Catppuccin-mocha = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat"; # Bat uses sublime syntax for its themes
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };

    btop.enable = true;
    eza.enable = true;

    skim = {
      enable = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  home = {
    shellAliases = {
    "..." = "cd ../..";
    df = "duf";
    cat = "bat";
    g = "git";
    grep = "rg";
    ip = "ip --color";
    jq = "jaq";
    l = "exa --icons --git";
    la = "l -la";
    lf = "joshuto";
    ll = "l -l";
    ls = "l";
    md = "mkdir -p";
    us = "systemctl --user";
    rs = "sudo systemctl";
    hm = ''
      f () { \
        [ -d $HOME/dotfiles ] && [ -e $HOME/dotfiles/flake.nix ] \
        || (echo "Please place dotfiles in $HOME" && return 1); \
        nix run $HOME/dotfiles "$@"; \
      }; f \
    '';
    hms = "hm switch";
    x = "xargs";
    xo = "xdg-open";
  };
    sessionVariables = {
      LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
      LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";

      # enable scrolling in git diff
      DELTA_PAGER = "less -R";

      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      DIRENV_LOG_FORMAT = "";
    };
  };
}
