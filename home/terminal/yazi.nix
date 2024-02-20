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
      # yazi file manager
      programs.yazi = {
        enable = true;

        package = inputs'.yazi.packages.default;

        enableBashIntegration = config.programs.bash.enable;
        enableZshIntegration = config.programs.zsh.enable;
        enableNushellIntegration = config.programs.nushell.enable;

        #catpuccin theme
        theme = {
          filetype = {
            rules = [
              {
                fg = "#94e2d5";
                mime = "image/*";
              }
              {
                fg = "#f9e2af";
                mime = "video/*";
              }
              {
                fg = "#f9e2af";
                mime = "audio/*";
              }
              {
                fg = "#f5c2e7";
                mime = "application/zip";
              }
              {
                fg = "#f5c2e7";
                mime = "application/gzip";
              }
              {
                fg = "#f5c2e7";
                mime = "application/x-tar";
              }
              {
                fg = "#f5c2e7";
                mime = "application/x-bzip";
              }
              {
                fg = "#f5c2e7";
                mime = "application/x-bzip2";
              }
              {
                fg = "#f5c2e7";
                mime = "application/x-7z-compressed";
              }
              {
                fg = "#f5c2e7";
                mime = "application/x-rar";
              }
              {
                fg = "#cdd6f4";
                name = "*";
              }
              {
                fg = "#89b4fa";
                name = "*/";
              }
            ];
          };
          help = {
            desc = {fg = "#9399b2";};
            exec = {fg = "#94e2d5";};
            footer = {
              bg = "#cdd6f4";
              fg = "#45475a";
            };
            hovered = {
              bg = "#585b70";
              bold = true;
            };
            on = {fg = "#f5c2e7";};
          };
          input = {
            border = {fg = "#89b4fa";};
            selected = {reversed = true;};
            title = {};
            value = {};
          };
          manager = {
            border_style = {fg = "#7f849c";};
            border_symbol = "│";
            cwd = {fg = "#94e2d5";};
            find_keyword = {
              fg = "#f9e2af";
              italic = true;
            };
            find_position = {
              bg = "reset";
              fg = "#f5c2e7";
              italic = true;
            };
            hovered = {
              bg = "#89b4fa";
              fg = "#1e1e2e";
            };
            marker_copied = {
              bg = "#f9e2af";
              fg = "#f9e2af";
            };
            marker_cut = {
              bg = "#f38ba8";
              fg = "#f38ba8";
            };
            marker_selected = {
              bg = "#a6e3a1";
              fg = "#a6e3a1";
            };
            preview_hovered = {underline = true;};
            syntect_theme = "~/.config/yazi/Catppuccin-mocha.tmTheme";
            tab_active = {
              bg = "#89b4fa";
              fg = "#1e1e2e";
            };
            tab_inactive = {
              bg = "#45475a";
              fg = "#cdd6f4";
            };
            tab_width = 1;
          };
          select = {
            active = {fg = "#f5c2e7";};
            border = {fg = "#89b4fa";};
            inactive = {};
          };
          status = {
            mode_normal = {
              bg = "#89b4fa";
              bold = true;
              fg = "#1e1e2e";
            };
            mode_select = {
              bg = "#a6e3a1";
              bold = true;
              fg = "#1e1e2e";
            };
            mode_unset = {
              bg = "#f2cdcd";
              bold = true;
              fg = "#1e1e2e";
            };
            permissions_r = {fg = "#f9e2af";};
            permissions_s = {fg = "#7f849c";};
            permissions_t = {fg = "#89b4fa";};
            permissions_w = {fg = "#f38ba8";};
            permissions_x = {fg = "#a6e3a1";};
            progress_error = {
              bg = "#45475a";
              fg = "#f38ba8";
            };
            progress_label = {
              bold = true;
              fg = "#ffffff";
            };
            progress_normal = {
              bg = "#45475a";
              fg = "#89b4fa";
            };
            separator_close = "";
            separator_open = "";
            separator_style = {
              bg = "#45475a";
              fg = "#45475a";
            };
          };
          tasks = {
            border = {fg = "#89b4fa";};
            hovered = {underline = true;};
            title = {};
          };
          which = {
            cand = {fg = "#94e2d5";};
            desc = {fg = "#f5c2e7";};
            mask = {bg = "#313244";};
            rest = {fg = "#9399b2";};
            separator = "  ";
            separator_style = {fg = "#585b70";};
          };
          icon.prepend_rules = [
            {
              name = "dev/";
              text = "";
            }
            {
              name = "docs/";
              text = "";
            }
            {
              name = "misc/";
              text = "";
            }
            {
              name = "download/";
              text = "";
            }
            {
              name = "private/";
              text = "";
            }
            {
              name = "media/";
              text = "";
            }
            {
              name = "pics/";
              text = "";
            }
          ];
        };
      };
    }
)
