{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  gitUser = config.programs.git.iniContent.user or {};
  hasIdentity = (gitUser.name or null) != null && (gitUser.email or null) != null;
  hasSigningKey = config.programs.git.signing.key != null;
  hasGhHosts = config.programs.gh.hosts != {};
in {
  config = {
    assertions = [
      {
        assertion = hasIdentity;
        message = ''
          `programs.git` is enabled but no commit identity is configured, so
          Git cannot create commits. Set both the name and the email in your
          profile, either on the new `settings` option or the legacy
          `userName`/`userEmail` pair:

            programs.git.settings.user = {
              name = "Jane Doe";
              email = "jane@example.com";
            };
        '';
      }
    ];

    warnings =
      optional (!hasSigningKey) ''
        `programs.git.signing.key` is not set, so commits and tags will not be
        signed. This is recommended for the full experience:

          programs.git.signing = {
            key = "0C159FAB320FEB35!";
            signByDefault = true;
          };
      ''
      ++ optional (!hasGhHosts) ''
        `programs.gh.hosts` is empty, so `gh` has no host configured and you
        will have to authenticate it by hand. This is recommended for the full
        experience:

          programs.gh.hosts."github.com".user = "your-username";
      '';

    programs = {
      git = {
        enable = true;
        attributes = [
          "*.pdf diff=pdf"
        ];
        lfs = {
          enable = true;
          skipSmudge = true;
        };
        settings = {
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
          advice = {
            detachedHead = false;
            skippedCherryPicks = false;
          };
          init.defaultBranch = "main";
          commit.verbose = true;
          alias = {
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
      };
      delta = {
        enable = true;
        enableGitIntegration = true;
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        extensions = [pkgs.gh-notify];
        settings = {
          git_protocol = "ssh";
        };
      };
      gh-dash = {
        enable = true;
        settings = {
          repoPaths = {
            ":owner/:repo" = "${config.xdg.userDirs.extraConfig.DEV}/GitHub/:owner/:repo";
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
      lazygit = {
        enable = true;
        settings.git.overrideGpg = true;
        settings.git.fetchAll = false;
      };
    };

    home = let
      ghq-fork = pkgs.writeShellScriptBin "ghq-fork" ''
        set -e

        if [ $# -ne 1 ]; then
          echo "Usage: ghq-fork owner/repo"
          exit 1
        fi

        repo="$1"
        name=''${repo#*/}
        owner=''${repo%/*}
        user=$(gh api user --jq .login)

        echo "🔁 Forking $repo..."
        gh repo fork "$repo"

        echo "📥 Cloning fork via ghq..."
        ghq get "$user/$name"

        echo "🔗 Setting upstream remote..."
        cd "$(ghq list -p "$user/$name")"
        git remote remove upstream 2>/dev/null || true
        git remote add upstream "https://github.com/$owner/$name.git"

        echo "📌 Adding to zoxide..."
        zoxide add .

        echo "✅ Done! Repo is ready at: $(pwd)"
      '';
    in {
      packages = with pkgs; [
        ghq
        git-branchless
        ghq-fork
      ];
      sessionVariables.GHQ_ROOT = "${config.xdg.userDirs.extraConfig.DEV}/Public";
    };
  };
}
