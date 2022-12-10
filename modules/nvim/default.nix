{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.nvim;
in
{
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {

    home.file.".config/nvim/lua".source = ./lua;

    programs.bash = {
      initExtra = ''
        export EDITOR="nvim"
      '';

      shellAliases = {
        v = "nvim -i NONE";
        nvim = "nvim -i NONE";
      };
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      withPython3 = true;
      extraPackages = with pkgs; [
        #--- LSP ---#
        rnix-lsp
        sumneko-lua-language-server
        gopls
        ccls
        pyright
        zk
        nodePackages.bash-language-server
        rust-analyzer
        #--null-ls--#
        stylua
        black
        nixpkgs-fmt
        rustfmt
        beautysh
        nodePackages.prettier
      ];
      extraLuaPackages = with pkgs.lua51Packages; [
        plenary-nvim
        luautf8
      ];

      plugins = with pkgs.vimPlugins; [
        # ----------------------------------------------
        # ------------Styling---------------------------
        # ----------------------------------------------
        nvim-web-devicons
        {
          plugin = catppuccin-nvim;
          config = "require('plugins.catppuccin')";
          type = "lua";
        }
        {
          plugin = indent-blankline-nvim;
          config = "require('indent_blankline').setup()";
          type = "lua";
        }
        nvim-ts-rainbow

        # ----------------------------------------------
        # ------------User Interface--------------------
        #-----------------------------------------------
        {
          plugin = bufferline-nvim;
          config = "require('plugins.bufferline')";
          type = "lua";
        }
        {
          plugin = lualine-nvim;
          config = "require('plugins.lualine')";
          type = "lua";
        }
        {
          plugin = gitsigns-nvim;
          config = "require('plugins.gitsigns')";
          type = "lua";
        }

        # ----------Apps-----------
        undotree
        markdown-preview-nvim
        {
          plugin = diffview-nvim;
          config = "require('plugins.diffview')";
          type = "lua";
        }
        {
          plugin = nvim-dap-ui;
          config = "require('plugins.dapui')";
          type = "lua";
        }
        {
          plugin = toggleterm-nvim;
          config = "require('plugins.toggleterm')";
          type = "lua";
        }
        {
          plugin = lspsaga-nvim;
          config = "require('plugins.lspsaga')";
          type = "lua";
        }

        #-----------------------------------------------
        # ------------Language Server Protocol----------
        #-----------------------------------------------
        rust-tools-nvim
        clangd_extensions-nvim
        {
          plugin = null-ls-nvim;
          config = "require('plugins.null-ls')";
          type = "lua";
        }
        {
          plugin = nvim-lspconfig;
          config = "require('plugins.lspconfig')";
          type = "lua";
        }

        # ------Auto-Completion----
        {
          plugin = nvim-cmp;
          config = "require('plugins.cmp')";
          type = "lua";
        }
        luasnip
        cmp_luasnip
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-buffer
        cmp-path
        lspkind-nvim

        # -----Highlighting--------
        {
          plugin = trouble-nvim;
          config = "require('trouble').setup()";
          type = "lua";
        }

        #-----------------------------------------------
        # ------------Search and Find-------------------
        #-----------------------------------------------
        telescope-media-files-nvim
        {
          plugin = telescope-nvim;
          config = "require('plugins.telescope')";
          type = "lua";
        }

        #-----------------------------------------------
        # ------------Editing Features------------------
        #-----------------------------------------------
        targets-vim
        nvim-ts-context-commentstring
        {
          plugin = comment-nvim;
          config = "require('plugins.comment')";
          type = "lua";
        }
        {
          plugin = nvim-surround;
          config = "require('nvim-surround').setup()";
          type = "lua";
        }
        {
          plugin = nvim-autopairs;
          config = "require('plugins.autopairs')";
          type = "lua";
        }

        #-----------------------------------------------
        # ------------Integration-----------------------
        #-----------------------------------------------
        #Zettelkasten
        {
          plugin = zk-nvim;
          config = "require('zk').setup()";
          type = "lua";
        }
        #Debug Adapter Protocol
        nvim-dap
        #Tree-Sitter
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = "require('plugins.treesitter')";
          type = "lua";
        }
        # Popup API from vim
        popup-nvim

        #-----------------------------------------------
        # ------------Miscellanous----------------------
        #-----------------------------------------------
        vim-startuptime
        {
          plugin = impatient-nvim;
          config = "require('plugins.impatient')";
          type = "lua";
        }
      ];
      extraConfig = ''
        luafile ~/.config/nvim/lua/settings.lua
      '';
    };
  };
}
