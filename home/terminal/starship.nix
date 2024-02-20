{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: hm @ {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
    in {
      config = {
        home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

        programs.starship = let
          flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
        in {
          enable = true;
          settings =
            {
              format = concatStrings [
                "[](mauve)$os$username"
                "[](bg:flamingo fg:mauve)$directory"
                "[](fg:flamingo bg:pink)$git_branch$git_commit"
                "$git_state$git_status[](fg:pink bg:lavender)"
                "$c$rust$golang$nodejs$php$java$kotlin"
                "$haskell$python[](fg:lavender bg:overlay0)"
                "$docker_context$nix_shell[](fg:overlay0 bg:surface0)"
                "$time[ ](fg:surface0)$character$line_break$shell"
              ];

              palette = "catppuccin_${flavour}";

              os = {
                disabled = false;
                style = "bg:mauve fg:base";
              };

              os.symbols = {
                Windows = "󰍲";
                Ubuntu = "󰕈";
                SUSE = "";
                Raspbian = "󰐿";
                Mint = "󰣭";
                Macos = "󰀵";
                Manjaro = "";
                NixOS = "󱄅 ";
                Linux = "󰌽";
                Gentoo = "󰣨";
                Fedora = "󰣛";
                Alpine = "";
                Amazon = "";
                Android = "";
                Arch = "󰣇";
                Artix = "󰣇";
                CentOS = "";
                Debian = "󰣚";
                Redhat = "󱄛";
                RedHatEnterprise = "󱄛";
              };

              username = {
                show_always = true;
                style_user = "bg:mauve fg:base";
                style_root = "bg:mauve fg:base";
                format = "[ $user ]($style)";
              };

              directory = {
                style = "fg:base bg:flamingo";
                format = "[ $read_only]($read_only_style)[$path]($style)";
                read_only = "󰌾 ";
                read_only_style = "fg:red bg:flamingo";
                truncation_length = 3;
                repo_root_format = "[$read_only]($read_only_style)[$repo_root]($repo_root_style)[$path]($style)";
                home_symbol = "󰋜 ";
              };

              directory.substitutions = {
                "docs" = "󰈙 ";
                "etc/download" = " ";
                "media/music" = "󰝚 ";
                "media/pic" = " ";
                "dev" = "󰲋 ";
              };

              git_branch = {
                symbol = "";
                style = "bg:pink";
                format = "[[ $symbol $branch ](fg:base bg:pink)]($style)";
              };

              git_commit = {
                style = "fg:base bg:pink";
                format = "[ $hash $tag]($style)";
              };

              git_state = {
                style = "fg:base bg:pink";
                format = "[\\($state( $progress_current of $progress_total)\\) ]($style)";
              };

              git_status = {
                style = "bg:pink";
                format = "[[($all_status$ahead_behind )](fg:base bg:pink)]($style)";
                conflicted = "󰞇 ";
                ahead = "󰚧 ";
                behind = "󰚰 ";
                diverged = "󰃻 ";
                up_to_date = "";
                untracked = " ";
                stashed = " ";
                modified = " ";
                staged = " ";
                renamed = " ";
                deleted = " ";
              };

              nodejs = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              c = {
                symbol = " ";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              rust = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              golang = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              php = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              java = {
                symbol = " ";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              kotlin = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              haskell = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              python = {
                symbol = "";
                style = "bg:lavender";
                format = "[[ $symbol( $version) ](fg:base bg:lavender)]($style)";
              };

              docker_context = {
                symbol = "";
                style = "bg:overlay0";
                format = "[[ $symbol( $context) ](fg:blue bg:overlay0)]($style)";
              };

              nix_shell = {
                style = "bold bg:overlay0";
                symbol = " 󱄅 ";
                impure_msg = "[impure shell]( red $style)";
                pure_msg = "[pure shell]( green $style)";
                unknown_msg = "[unknown shell]( yellow $style)";
                format = "[[$symbol$state( \($name\))](blue $style)]($style)";
              };

              time = {
                disabled = false;
                time_format = "%R";
                style = "bg:surface0";
                format = "[[  $time ](fg:text bg:surface0)]($style)";
              };

              line_break = {
                disabled = false;
              };

              shell = {
                disabled = false;
                bash_indicator = "[ ❯](bold green)";
                nu_indicator = "[󰟆 ❯](bold green)";
              };

              character = {
                disabled = false;
                success_symbol = "";
                error_symbol = "[ ](bold fg:red)";
              };
            }
            // builtins.fromTOML (
              builtins.readFile
              (pkgs.fetchFromGitHub {
                  owner = "catppuccin";
                  repo = "starship";
                  rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f"; # Replace with the latest commit hash
                  sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
                }
                + /palettes/${flavour}.toml)
            );
        };
      };
    }
)
