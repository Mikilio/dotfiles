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
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        autocd = true;
        dirHashes = {
          dl = "$HOME/etc/download";
          docs = "$HOME/docs";
          code = "$HOME/dev/";
          dots = "$HOME/dotfiles";
          pics = "$HOME/media/pics";
          vids = "$HOME/media/videos/";
          nixpkgs = "$HOME/dev/nixpkgs";
        };
        dotDir = ".config/zsh";
        history = {
          expireDuplicatesFirst = true;
          path = "${config.xdg.dataHome}/zsh_history";
        };

        initExtra = ''
          # search history based on what's typed in the prompt
          autoload -U history-search-end
          zle -N history-beginning-search-backward-end history-search-end
          zle -N history-beginning-search-forward-end history-search-end
          bindkey "^[OA" history-beginning-search-backward-end
          bindkey "^[OB" history-beginning-search-forward-end

          # case insensitive tab completion
          zstyle ':completion:*' completer _complete _ignored _approximate
          zstyle ':completion:*' list-colors '\'
          zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
          zstyle ':completion:*' menu select
          zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
          zstyle ':completion:*' verbose true
          _comp_options+=(globdots)

          ${lib.optionalString config.services.gpg-agent.enable ''
            gnupg_path=$(ls $XDG_RUNTIME_DIR/gnupg)
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/$gnupg_path/S.gpg-agent.ssh"
          ''}

          ${lib.optionalString config.programs.kitty.enable ''
            if test -n "$KITTY_INSTALLATION_DIR"; then
              export KITTY_SHELL_INTEGRATION="enabled"
              autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
              kitty-integration
              unfunction kitty-integration
            fi
          ''}

          # run programs that are not in PATH with comma
          command_not_found_handler() {
            ${pkgs.comma}/bin/comma "$@"
          }
        '';
      };
      zoxide.enableZshIntegration = true;
      skim.enableZshIntegration = true;
      wezterm. enableZshIntegration = true;
      direnv.enableZshIntegration = true;
    };
  };
}
