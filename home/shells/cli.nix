{pkgs, ...}: {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unar
    unrar-wrapper

    # utils
    file
    du-dust
    duf
    fd
    bat
    ripgrep
    xdg-utils

  ];

  programs = {
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
    ssh.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  home.shellAliases = {
    df = "duf";
    g = "git";
    grep = "rg";
    cat = "bat";
    ip = "ip --color";
    l = "exa --icons --git";
    la = "l -la";
    lf = "joshuto";
    ll = "l -l";
    ls = "l";
    md = "mkdir -p";
    x = "xargs";
    "..." = "cd ../..";
    us = "systemctl --user";
    rs = "sudo systemctl";
    hm = "f () { [ -d $HOME/dotfiles ] && nix run $HOME/dotfiles \"$@\" || echo \"Please place dotfiles in $HOME\"; }; f";
  };
}
