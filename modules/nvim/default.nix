{ lib, config, pkgs, ... }:
with lib;
let
cfg = config.modules.nvim;
lsp-zero = pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "lsp-zero-nvim";
  src = pkgs.fetchFromGitHub {
    owner = "VonHeikemen";
    repo = "lsp-zero.nvim";
    rev = "dfe0c552442114e1fc9fa93589ef84eb460f368a";
    hash = "sha256-KfHgZKlJ4m3v/d/XBaCHSMgl62XUNl3i8Xpi4oGPqkI=";
  };
};
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
          ccls
          pyright
          zk
          nodePackages.bash-language-server
          rust-analyzer
          texlab
#--null-ls--#
          stylua
          black
          nixpkgs-fmt
          rustfmt
          beautysh
          nodePackages.prettier
      ];
      extraLuaPackages = lua: with lua; [
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
        config = "require('plugins.indent-blankline')";
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
      {
        plugin = alpha-nvim;
        config = "require('plugins.alpha')";
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
      null-ls-nvim
      {
        plugin = nvim-lspconfig;
        config = "require('plugins.lsp')";
        type = "lua";
      }

# ------Auto-Completion----
        cmp-buffer
        cmp-path
        cmp_luasnip
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-nvim-lua
        cmp-omni
        cmp-rg
        cmp-spell
        {
          plugin = nvim-cmp;
          config = "require('plugins.cmp')";
          type = "lua";
        }

# ------Snippets-----------
        luasnip
        friendly-snippets

#-----------------------------------------------
# ------------Search and Find-------------------
#-----------------------------------------------
        telescope-media-files-nvim
        telescope-project-nvim
        telescope-fzy-native-nvim
        git-worktree-nvim
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
      {
        plugin = hop-nvim;
        config = "require('plugins.hop')";
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

# LaTex
      {
        plugin = vimtex;
        config = "require('plugins.vimtex')";
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

# Pop-up API from vim
      popup-nvim

# git-worktrees
        git-worktree-nvim

#-----------------------------------------------
# ------------Miscellaneous----------------------
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
