{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  config = {
    programs = {
      git = {
        enable = true;
        userName = "Mikilio";
        userEmail = "official.mikilio@gmail.com";
        delta.enable = true;
        signing = {
          signByDefault = true;
          key = "0C159FAB320FEB35!";
        };
        attributes = [
          "*.pdf diff=pdf"
        ];
        lfs = {
          enable = true;
          skipSmudge = true;
        };
        extraConfig = {
          interactive.singleKey = true;
          format.signoff = true;
          color = {
            branch = true;
            diff = true;
            status = true;
          };
          push.recurseSubmodules = "on-demand";
          am.threeWay = true;
          diff = {
            renames = true;
            colorMoved = true;
          };
          merge = {
            tool = "vimdiff";
            conflictStyle = "zdiff3";
          };
          push = {
            default = "simple";
            autoSetupRemote = true;
          };
          rerere = {
            autoUpdate = true;
            enabled = true;
          };
          branch.autoSetupRebase = "always";
          pull.rebase = true;
          rebase = {
            stat = true;
            autoStash = true;
            autoSquash = true;
            updateRefs = true;
          };
          mergetool.prompt = false;
          sendemail = {
            smtpServer = "smtp.gmail.com";
            smtpServerPort = 587;
            smtpEncryption = "tls";
            smtpUser = "official.mikilio@gmail.com";
          };
          credential."smtp://smtp.gmail.com:587".helper = ''
            !f() { echo username=official.mikilio@gmail.com; echo "password=$(cat ${config.sops.secrets.google-git.path})"; }; f 2> /dev/null
          '';
          advice = {
            detachedHead = false;
            skippedCherryPicks = false;
          };
          init.defaultBranch = "main";
          commit.verbose = true;
        };
        aliases = {
          rb = "rebase origin/HEAD";
          get = "clone --recursive";
          blame = "-w -M";
          update = "!git pull && git submodule update --init --recursive";
          comma = "commit --amend";
          uncommit = "reset --soft HEAD^";
          pr = "!\"pr() { git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; pr\"";
          backport = "cherry-pick -x";
          reset-pr = "reset --hard FETCH_HEAD";
          force-push = "push --force-with-lease";
          publish = "!git pull && git push";
          # recover failed commit messages: https://stackoverflow.com/questions/9133526/git-recover-failed-commits-message
          recommit = "!git commit -eF $(git rev-parse --git-dir)/COMMIT_EDITMSG";
        };
      };
      gh = {
        enable = true;
        hosts = {
          "github.com" = {
            user = "Mikilio";
          };
        };
        gitCredentialHelper.enable = true;
        extensions = [pkgs.gh-notify];
        settings = {
          git_protocol = "ssh";
          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
      gh-dash = {
        enable = true;
        settings = {
          repoPaths = {
            ":owner/:repo" = "${config.xdg.userDirs.extraConfig.XDG_DEV_DIR}/GitHub/:owner/:repo";
            "Mikilio/*" = "${config.xdg.userDirs.extraConfig.XDG_DEV_DIR}/GitHub/*";
          };
          pager = {
            diff = "delta --side-by-side";
          };
          theme = {
            ui = {
              sectionsShowCount = true;
              table = {
                showSeparator = true;
              };
            };
            colors = {
              text = {
                primary = "#CDD6F4";
                secondary = "#CBA6F7";
                inverted = "#11111B";
                faint = "#BAC2DE";
                warning = "#F9E2AF";
                success = "#A6E3A1";
                error = "#F38BA8";
              };
              background = {
                selected = "#313244";
              };
              border = {
                primary = "#CBA6F7";
                secondary = "#45475A";
                faint = "#313244";
              };
            };
          };
        };
      };
      lazygit.enable = true;
    };

    home = let
      ghq-fork = pkgs.writeShellScriptBin "ghq-fork" ''
        set -e

        if [ $# -ne 1 ]; then
          echo "Usage: gh ghq owner/repo"
          exit 1
        fi

        repo="$1"
        name=''${repo#*/}
        owner=''${repo%/*}
        user=$(gh api user --jq .login)

        echo "🔁 Forking $repo..."
        gh repo fork "$repo" --remote=false

        echo "📥 Cloning fork via ghq..."
        ghq get "$user/$name"

        echo "🔗 Setting upstream remote..."
        cd "$(ghq list -p "$user/$name")"
        git remote add upstream "https://github.com/$owner/$name.git"

        echo "📌 Adding to zoxide..."
        zoxide add .

        echo "✅ Done! Repo is ready at: $(pwd)"


      '';
    in {
      packages = with pkgs; [
        ghq
        ghorg
        git-branchless
        ghq-fork
      ];
      sessionVariables.GHQ_ROOT = "${config.xdg.userDirs.extraConfig.XDG_DEV_DIR}/Public";
    };
    xdg.configFile."ghorg/conf.yaml" = {
      force = true;
      text =
        # yml
        ''
          GHORG_ABSOLUTE_PATH_TO_CLONE_TO: ${config.xdg.userDirs.extraConfig.XDG_DEV_DIR}/Org
          GHORG_CLONE_PROTOCOL: ssh
          GHORG_GITHUB_TOKEN: ${config.sops.secrets.github.path}

        '';
    };
  };
}
