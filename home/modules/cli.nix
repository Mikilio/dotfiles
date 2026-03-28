{
  options,
  lib,
  pkgs,
  ...
}: let
  preview = pkgs.writeShellScript "preview.sh" (
    builtins.readFile (
      builtins.fetchurl {
        url = "https://raw.githubusercontent.com/lotabout/skim.vim/4145f53f3d343c389ff974b1f1a68eeb39fba18b/bin/preview.sh";
        sha256 = "1ilfqcxvaxw906sdy4aqk9lyw3i1qwi00dvj3vhvygi90ja3qhhw";
      }
    )
  );
in {
  config = {
    home =
      {
        shell = {
          enableBashIntegration = true;
          enableNushellIntegration = true;
        };

        packages = with pkgs; [
          # archives
          zip
          unzip
          unar

          #TUI
          calcurse

          # utils
          jaq
          file
          dust
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

          #DevOps
          kubectl
        ];
        shellAliases = {
          # === External commands (work everywhere) ===
          ping = "ping -c 10";
          x = "xargs";
          cls = "clear";
          multitail = "multitail --no-repeat -c";

          # === chmod (only safe/useful ones) ===
          mx = "chmod o+x";
          m644 = "chmod -R 644";
          m600 = "chmod -R 600";
          m700 = "chmod -R 700";
          m755 = "chmod -R 755";

          # === Archives ===
          mktar = "tar -cvf";
          mkbz2 = "tar -cvjf";
          mkgz = "tar -cvzf";
          untar = "tar -xvf";
          unbz2 = "tar -xvjf";
          ungz = "tar -xvzf";

          # === System ===
          us = "systemctl --user";
          rs = "sudo systemctl";
          xo = "xdg-open";
          hm = "home-manager";
          openports = "netstat -nape --inet";

          # === Git ===
          g = "git";
          gst = "git status";
          gp = "git push origin HEAD";
          gpu = "git pull origin";
          gco = "git checkout";
          gb = "git branch";
          ga = "git add -p";
          gdiff = "git diff";

          # === Kubernetes ===
          k = "kubectl";
          kg = "kubectl get";
          kd = "kubectl describe";
          kdel = "kubectl delete";
          kl = "kubectl logs -f";
          kgpo = "kubectl get pod";
          ke = "kubectl exec -it";
        };

        sessionVariables = {
          CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";

          DIRENV_LOG_FORMAT = "";
        };
        sessionPath = ["$HOME/.local/share/bin"];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/storage" = {
          directories = [
            {
              directory = ".local/share/zoxide";
              mode = "0700";
            }
            {
              directory = ".local/share/atuin";
              mode = "0700";
            }
          ];
        };

        persistence."/persistent/cache" = {
          directories = [
            {
              directory = ".cache/nix-index";
              mode = "0700";
            }
            {
              directory = ".cache/nix-search-tv";
              mode = "0700";
            }
            {
              directory = ".local/share/devenv";
              mode = "0700";
            }
            {
              directory = ".local/share/direnv";
              mode = "0700";
            }
          ];
        };
      };

    programs = {
      bash = {
        enable = true;
        enableCompletion = false;
        historyFileSize = 0;
        historyControl = [
          "ignoreboth"
          "erasedups"
        ];
        historyIgnore = [
          "&"
          "[bf]g"
          "exit"
          "reset"
          "clear"
        ];
        shellOptions = [
          "autocd"
          "cdspell"
          "dirspell"
          "extglob"
          "globstar"
          "no_empty_cmd_completion"
          "checkwinsize"
          "checkhash"
          "histverify"
          "histreedit"
          "cmdhist"
        ];
        bashrcExtra = ''
          set -o notify           # notify of completed background jobs immediately
          set -o noclobber        # don\'t overwrite files by accident
          ulimit -S -c 0          # disable core dumps
          # if [ -t 0 ]; then
          #   stty -ctlecho;        #turn off control character echoing
          # fi
          unset HISTFILE
        '';
        initExtra = ''
          source "${lib.getExe pkgs.complete-alias}"
          complete -F _complete_alias "''${!BASH_ALIASES[@]}"
        '';
        shellAliases = {
          # === Bash-only navigation ===
          ".." = "cd ..";
          "..." = "cd ../..";
          bd = "cd \"$OLDPWD\"";

          # === Override Nushell built-ins with external commands ===
          rm = "rm -iv";
          cat = "bat";
          cp = "cp -i";
          mv = "mv -i";
          mkdir = "mkdir -p";

          # === Uses flags Nushell rm doesn't have ===
          rmd = "rm --recursive --force --verbose";

          # === Eza ===
          l = "eza --all";
          ll = "eza --long";
          lt = "eza --tree --level=2 --long --git";
        };
      };

      bat = {
        enable = true;
        config = {
          pager = "less -FR";
        };
      };

      btop.enable = true;

      carapace = {
        enable = true;
        ignoreCase = true;
      };

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      eza = {
        enable = true;
        git = true;
        icons = "auto";
      };
      atuin = {
        enable = true;
        daemon.enable = true;
        forceOverwriteSettings = true;
        settings.filter_mode_shell_up_key_binding = "session";
      };
      less = {
        enable = true;
        config = ''
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

      nix-index = {
        enable = true;
      };

      nix-search-tv = {
        enable = true;
        enableTelevisionIntegration = true;
      };

      nix-your-shell.enable = true;

      nushell = {
        enable = true;
        shellAliases = {
          cat = "bat";
          l = "ls -a";
          ll = "ls -l";
          # Tree view - eza is actually useful here since Nushell has no tree
          lt = "eza --tree --level=2 --long --icons --git";
        };
        extraConfig = ''
          $env.config.show_banner = false
          $env.config.edit_mode = "vi"

          # rmd equivalent
          def rmd [...paths: path] {
            rm -r -f ...$paths
          }
        '';
      };

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
          skip-completed-text = true;
          visible-stats = true;
        };
      };

      starship = {
        enable = true;
        presets = ["nerd-font-symbols"];
        settings = {
          shell.disabled = false;
        };
      };

      television = {
        enable = true;
      };

      zoxide = {
        enable = true;
      };
    };
  };
}
