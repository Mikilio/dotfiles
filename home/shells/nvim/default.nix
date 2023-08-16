{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.preferences.cli.editor;
  customPlugs = config.nur.repos.mikilio.overlays.vimPlugins;

in
{
  config = mkIf (cfg == "neovim") {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;
      extraPackages = with pkgs; [

        #--- LSP ---#
        ccls
        nixd
        pyright
        lua-language-server
        nodePackages.bash-language-server
        rust-analyzer
        texlab
        ltex-ls
        #---misc----#
        cmark-gfm
        nodePackages.live-server
      ];
      extraLuaPackages = lua:
        with lua; [
          plenary-nvim
          luaposix
          luautf8
        ];

      plugins = with (pkgs.vimPlugins.extend customPlugs);
        with builtins; [
          # ----------------------------------------------
          # ------------Styling---------------------------
          # ----------------------------------------------
          nvim-web-devicons
          {
            plugin = catppuccin-nvim;
            config = readFile ./lua/plugins/catppuccin.lua;
            type = "lua";
          }
          {
            plugin = indent-blankline-nvim;
            config = readFile ./lua/plugins/indent-blankline.lua;
            type = "lua";
          }
          nvim-ts-rainbow

          # ----------------------------------------------
          # ------------User Interface--------------------
          #-----------------------------------------------
          {
            plugin = lualine-nvim;
            config = readFile ./lua/plugins/lualine.lua;
            type = "lua";
          }
          {
            plugin = gitsigns-nvim;
            config = readFile ./lua/plugins/gitsigns.lua;
            type = "lua";
          }
          {
            plugin = alpha-nvim;
            config = readFile ./lua/plugins/alpha.lua;
            type = "lua";
          }
          # ----------Apps-----------
          {
            plugin = knap;
            config = readFile ./lua/plugins/knap.lua;
            type = "lua";
          }
          {
            plugin = nvim-dap-ui;
            config = readFile ./lua/plugins/dapui.lua;
            type = "lua";
          }
          #-----------------------------------------------
          # ------------Language Server Protocol----------
          #-----------------------------------------------
          lsp-zero-nvim
          lspkind-nvim
          nvim-navic
          ltex_extra-nvim
          {
            plugin = nvim-lspconfig;
            config = readFile ./lua/plugins/lsp.lua;
            type = "lua";
          }

          # ------Auto-Completion----
          nvim-cmp
          cmp-buffer
          cmp-path
          cmp_luasnip
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-nvim-lua
          
          # ------Snippets-----------
          luasnip

          #-----------------------------------------------
          # ------------Search and Find-------------------
          #-----------------------------------------------
          telescope-media-files-nvim
          telescope-project-nvim
          telescope-zoxide
          telescope-fzy-native-nvim
          telescope-undo-nvim
          git-worktree-nvim
          {
            plugin = telescope-nvim;
            config = readFile ./lua/plugins/telescope.lua;
            type = "lua";
          }

          #-----------------------------------------------
          # ------------Editing Features------------------
          #-----------------------------------------------
          targets-vim
          nvim-ts-context-commentstring
          {
            plugin = harpoon;
            config = readFile ./lua/plugins/harpoon.lua;
            type = "lua";
          }
          {
            plugin = comment-nvim;
            config = readFile ./lua/plugins/comment.lua;
            type = "lua";
          }
          {
            plugin = nvim-surround;
            config = "require('nvim-surround').setup()";
            type = "lua";
          }
          {
            plugin = nvim-autopairs;
            config = readFile ./lua/plugins/autopairs.lua;
            type = "lua";
          }
          {
            plugin = hop-nvim;
            config = readFile ./lua/plugins/hop.lua;
            type = "lua";
          }

          #-----------------------------------------------
          # ------------Integration-----------------------
          #-----------------------------------------------

          #Debug Adapter Protocol
          nvim-dap

          #TeXMagic
          {
            plugin = texmagic-nvim;
            config = "require('texmagic').setup{}";
            type = "lua";
          }

          #Tree-Sitter
          {
            plugin = nvim-treesitter.withAllGrammars;
            config = readFile ./lua/plugins/treesitter.lua;
            type = "lua";
          }

          # Pop-up API from vim
          popup-nvim

          # Git
          git-worktree-nvim
          {
            plugin = vim-fugitive;
            config = readFile ./lua/plugins/fugitive.lua;
            type = "lua";
          }

          # Zoxide
          zoxide-vim

          #-----------------------------------------------
          # ------------Miscellaneous----------------------
          #-----------------------------------------------

          {
            plugin = netrw-nvim;
            config = "require('netrw').setup{}";
            type = "lua";
          }
          {
            plugin = impatient-nvim;
            config = readFile ./lua/plugins/impatient.lua;
            type = "lua";
          }

        ];
      extraLuaConfig =
        let
          luaRequire = module:
            builtins.readFile (builtins.toString
              ./lua
            + "/${module}.lua");
          luaConfig = builtins.concatStringsSep "\n" (map luaRequire [
            "settings"
            "keymaps"
          ]);
        in
        ''
          ${luaConfig}
        '';
    };
  };
}
