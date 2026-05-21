{
  options,
  lib,
  pkgs,
  config,
  ...
}: {
  config = {
    home =
      {
        packages = with pkgs; [
          dragon-drop
          xdg-desktop-portal-termfilechooser
          libsecret
          mediainfo
          ouch
          glib
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
            ".local/share/yazi"
            {
              directory = ".local/share/Trash";
              mode = "0700";
            }
          ];
        };
      };

    xdg = {
      portal = {
        config.common."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
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
        inherit (pkgs.yaziPlugins) chmod ouch gvfs mediainfo;
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
        plugin = let
          username = config.home.username;
          media = [
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              url = "*.{ai,eps,ait}";
              run = "mediainfo";
            }

            # Adobe Illustrator
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
            {
              mime = "application/illustrator";
              run = "mediainfo";
            }
            {
              mime = "application/dvb.ait";
              run = "mediainfo";
            }
            {
              mime = "application/vnd.adobe.illustrator";
              run = "mediainfo";
            }
            {
              mime = "image/x-eps";
              run = "mediainfo";
            }
            {
              mime = "application/eps";
              run = "mediainfo";
            }
          ];
          gvfs = [
            # Do not preload files in mounted locations
            {
              name = "/run/user/1000/gvfs/**/*";
              run = "noop";
            }
            # For mounted hard disk/drive
            {
              name = "/run/media/${username}/**/*";
              run = "noop";
            }
          ];
        in {
          prepend_preloaders = gvfs ++ media;
          prepend_previewers =
            [
              # Allow to preview folder
              {
                name = "*/";
                run = "folder";
              }
              # Existing ouch previewer
              {
                mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
                run = "ouch";
              }
            ]
            ++ gvfs ++ media;
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["<C-n>"];
            run = ''
              shell 'dragon-drop -x -i -T "$1"' --confirm
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
          # GVFS Mount keybindings
          {
            on = ["M" "m"];
            run = "plugin gvfs -- select-then-mount --jump";
            desc = "Select device to mount and jump to its mount point";
          }
          {
            on = ["M" "R"];
            run = "plugin gvfs -- remount-current-cwd-device";
            desc = "Remount device under cwd";
          }
          {
            on = ["M" "u"];
            run = "plugin gvfs -- select-then-unmount --eject";
            desc = "Select device then eject";
          }
          {
            on = ["M" "U"];
            run = "plugin gvfs -- select-then-unmount --eject --force";
            desc = "Select device then force to eject/unmount";
          }
          {
            on = ["M" "a"];
            run = "plugin gvfs -- add-mount";
            desc = "Add a GVFS mount URI";
          }
          {
            on = ["M" "e"];
            run = "plugin gvfs -- edit-mount";
            desc = "Edit a GVFS mount URI";
          }
          {
            on = ["M" "r"];
            run = "plugin gvfs -- remove-mount";
            desc = "Remove a GVFS mount URI";
          }
          {
            on = ["g" "m"];
            run = "plugin gvfs -- jump-to-device --automount";
            desc = "Automount then select device to jump to its mount point";
          }
          {
            on = ["\`" "\`"];
            run = "plugin gvfs -- jump-back-prev-cwd";
            desc = "Jump back to the position before jumped to device";
          }
          {
            on = ["M" "t"];
            run = "plugin gvfs -- automount-when-cd";
            desc = "Enable automount when cd to device under cwd";
          }
          {
            on = ["M" "T"];
            run = "plugin gvfs -- automount-when-cd --disabled";
            desc = "Disable automount when cd to device under cwd";
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
            name = "Nexus";
            text = "";
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
