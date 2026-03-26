{
  options,
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    home =
      {
        packages = with pkgs; [
          dragon-drop
          xdg-desktop-portal-termfilechooser
          ouch
          (
            pkgs.writeShellScriptBin "btrfs" ''
              exec /run/wrappers/bin/pkexec ${pkgs.btrfs-progs}/bin/btrfs "$@"
            ''
          )
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/storage" = {
          directories = [
            {
              directory = ".local/share/Trash";
              mode = "0700";
            }
          ];
        };
      };

    xdg = {
      portal = {
        config.hyprland."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
        extraPortals = [pkgs.xdg-desktop-portal-termfilechooser];
      };

      configFile."xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        default_dir=$HOME/Downloads
      '';
    };
    # yazi file manager
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      initLua = ./init.lua;

      plugins = {
        inherit (pkgs.yaziPlugins) chmod ouch;
        snapshots = pkgs.nur.repos.mikilio.snapshot-yazi;
      };

      settings = {
        manager.show_symlink = false;
        opener = {
          extract = [
            {
              run = ''ouch d -y "$@"'';
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];
        };
        plugin.prepend_previewers = [
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch";
          }
        ];
      };

      keymap = {
        mgr.prepend_keymap = [
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
            on = ["!"];
            run = "shell '$SHELL' --block --confirm";
            desc = "Open shell here";
          }
          {
            on = "<Esc>";
            run = "close";
            desc = "Cancel input";
          }
          {
            on = ["c" "m"];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = ["C"];
            run = "plugin ouch";
            desc = "Compress with ouch";
          }
          {
            on = ["g" "s"];
            run = "plugin snapshots";
            desc = "Browse path in snapshots";
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
  };
}
