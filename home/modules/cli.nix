{
  config,
  lib,
  pkgs,
  ...
}: let
  preview = pkgs.writeShellScript "preview.sh" (builtins.readFile (builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lotabout/skim.vim/4145f53f3d343c389ff974b1f1a68eeb39fba18b/bin/preview.sh";
    sha256 = "1ilfqcxvaxw906sdy4aqk9lyw3i1qwi00dvj3vhvygi90ja3qhhw";
  }));
in {
  home.packages =
    [
      config.nur.repos.mikilio.xdg-terminal-exec
    ]
    ++ (with pkgs; [
      # archives
      zip
      unzip
      unar

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

      #nix
      sops
      alejandra
      deadnix
      statix
      cachix
      devenv
    ]);

  programs = {
    bash = {
      enable = true;
      enableCompletion = false;
      historyControl = ["ignoredups" "ignorespace" "erasedups"];
      historyIgnore = ["&" "ls" "[bf]g" "exit" "reset" "clear" "cd*"];
      shellOptions = [
        "autocd"
        "cdspell"
        "dirspell"
        "extglob"
        "no_empty_cmd_completion"
        "checkwinsize"
        "checkhash"
        "histverify"
        "histappend"
        "histreedit"
        "cmdhist"
      ];
      bashrcExtra = ''
        set -o notify           # notify of completed background jobs immediately
        set -o noclobber        # don\'t overwrite files by accident
        ulimit -S -c 0          # disable core dumps
        stty -ctlecho           # turn off control character echoing
      '';
      initExtra = ''
        source "${lib.getExe pkgs.complete-alias}"
        complete -F _complete_alias "''${!BASH_ALIASES[@]}"
      '';
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
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
      git = true;
      icons = true;
    };
    atuin = {
      enable = true;
      flags = ["--disable-up-arrow"];
    };
    less = {
      enable = true;
      keys = ''
        #env
        LESS = --quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4
        LESS_TERMCAP_mb = [01;31m
        LESS_TERMCAP_md = [01;36m
        LESS_TERMCAP_me = [0m
        LESS_TERMCAP_se = [0m
        LESS_TERMCAP_so = [1;44;33m
        LESS_TERMCAP_ue = [0m
        LESS_TERMCAP_us = [01;32m
      '';
    };
    lesspipe.enable = true;
    readline = {
      enable = true;
      bindings = {
        "\\e[6~" = "menu-complete";
        "\\e[5~" = "menu-complete-backward";
      };
      variables = {
        editing-mode = "vi";
        vi-ins-mode-string = "\\1\\e[6 q\\2";
        vi-cmd-mode-string = "\\1\\e[2 q\\2";
        show-mode-in-prompt = true;
        revert-all-at-newline = true;
        colored-stats = true;
        colored-completion-prefix = true;
        completion-ignore-case = true;
        completion-prefix-display-length = 3;
        mark-symlinked-directories = true;
        show-all-if-ambiguous = true;
        show-all-if-unmodified = true;
        skip-completed = true;
        visible-stats = true;
      };
    };
    skim = {
      enable = true;
      defaultCommand = "rg --color=always --line-number '{}'";
      defaultOptions = ["--ansi" "--preview '${preview} {}'"];
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
      cat = "bat";
      mkdir = "mkdir -p";
      ping = "ping -c 10";
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
      xo = "xdg-open";
      hm = "home-manager";
    };
    sessionVariables = {
      CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";

      DIRENV_LOG_FORMAT = "";
    };
    sessionPath = ["$HOME/.local/share/bin"];
  };
}
