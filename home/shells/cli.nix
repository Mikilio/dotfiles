{ config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unar
    unrar-wrapper

    # utils
    jq
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
        Catppuccin-mocha = builtins.readFile (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme";
          hash = "sha256-qMQNJGZImmjrqzy7IiEkY5IhvPAMZpq0W6skLLsng/w=";
        });
      };
    };

    btop.enable = true;
    exa.enable = true;

    skim = {
      enable = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  home.shellAliases = {
    "..." = "cd ../..";
    df = "duf";
    cat = "bat";
    g = "git";
    grep = "rg";
    ip = "ip --color";
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
}
