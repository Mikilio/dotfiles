{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
hm@{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let


in {
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

    #nix
    alejandra
    deadnix
    statix
    cachix
  ];

  programs = {

    bash = {
      enable = true;
      enableCompletion = false;
    };

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
    broot.enable = true;
    carapace.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };
    atuin = {
      enable = true;
      flags = [  "--disable-up-arrow" ];
    };
    skim = {
      enable = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
    zoxide.enable = true;
  };

  sops.secrets.cachix.path = "${config.xdg.configHome}/cachix/cachix.dhall";

  home = {
    shellAliases = {
      
      # Alias's to modified commands
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -iv";
      grep = "rg";
      cat = "bat";
      mkdir = "mkdir -p";
      ping = "ping -c 10";
      less = "less -R";
      x = "xargs";
      g = "git";
      cls = "clear";
      multitail = "multitail --no-repeat -c";
      
      # Change directory aliases
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # cd into the old directory
      bd = "cd \"$OLDPWD\"";
      
      # Remove a directory and all files
      rmd = "/bin/rm  --recursive --force --verbose ";
      
      # alias chmod commands
      mx = "chmod a+x";
      m000 = "chmod -R 000";
      m644 = "chmod -R 644";
      m666 = "chmod -R 666";
      m755 = "chmod -R 755";
      m777 = "chmod -R 777";
      
      # Show open ports
      openports = "netstat -nape --inet";
      
      # Alias's for archives
      mktar = "tar -cvf";
      mkbz2 = "tar -cvjf";
      mkgz = "tar -cvzf";
      untar = "tar -xvf";
      unbz2 = "tar -xvjf";
      ungz = "tar -xvzf";

      # Alias's for systemcontrol
      us = "systemctl --user";
      rs = "sudo systemctl";
      hm = ''
        func () { \
          [ -d $HOME/dotfiles ] && [ -e $HOME/dotfiles/flake.nix ] \
          || (echo "Please place dotfiles in $HOME" && return 1); \
          nix run $HOME/dotfiles "$@"; \
        }; func \
      '';
      hms = "hm switch";
      xo = "xdg-open";
  };
    sessionVariables = {
      LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
      LESSKEY = "$XDG_CONFIG_HOME/less/lesskey";

      # enable scrolling in git diff
      DELTA_PAGER = "less -R";

      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      DIRENV_LOG_FORMAT = "";
      CARAPACE_BRIDGES = "zsh,fish,bash,inshellisenscse";
    };
  };
})
