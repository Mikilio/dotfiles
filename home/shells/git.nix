{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let

  cfg = config.preferences.cli.shell;

in {
  config = mkIf (!isNull cfg) {

    home.packages = [
      pkgs.git-crypt
    ];

    programs.git = {
      enable = true;
      userName = "Mikilio";
      userEmail = "official.mikilio@gmail.com";
      delta.enable = true;
      signing = {
        signByDefault = true;
        key = "5B2F1A890CF33F3F!";
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
        credential.helper = "";
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
        pr = ''
          !"pr() { git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; pr"
        '';
        backport = "cherry-pick -x";
        reset-pr = "reset --hard FETCH_HEAD";
        force-push = "push --force-with-lease";
        publish = "!git pull && git push";
        # recover failed commit messages: https://stackoverflow.com/questions/9133526/git-recover-failed-commits-message
        recommit = "!git commit -eF $(git rev-parse --git-dir)/COMMIT_EDITMSG";
      };
    };
  };
}
