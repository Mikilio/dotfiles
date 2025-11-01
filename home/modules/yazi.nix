{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  home.packages = with pkgs; [dragon-drop];
  # yazi file manager
  programs.yazi = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;

    settings = {
      manager.show_symlink = false;
    };

    keymap = {
      manager.prepend_keymap = [
        {
          on = ["<C-n>"];
          run = ''
            shell 'dragon -x -i -T "$1"' --confirm
          '';
          desc = ''Drag and Drop item'';
        }
        {
          on = ["y"];
          run = [
            "yank"
            ''
              shell --confirm 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list'
            ''
          ];
        }
        {
          on = ["<C-s>"];
          run = "shell '$SHELL' --block --confirm";
          desc = "Open shell here";
        }
      ];
    };

    theme = {
      icon.prepend_dirs = [
        {
          name = "Code";
          text = "";
        }
        {
          name = "Templates";
          text = "";
        }
        {
          name = "Nexus";
          text = "";
        }
        {
          name = "Documents";
          text = "󰂺";
        }
        {
          name = "Public";
          text = "";
        }
      ];
    };
  };
}
