{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.shells;
  cmd = "nvim -i NONE";
  texmagic = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "texmagic-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "jakewvincent";
      repo = "texmagic.nvim";
      rev = "3c0d3b63c62486f02807663f5c5948e8b237b182";
      hash = "sha256-+IltvS5R9st+b97PtEdDnflymSP2JFpmqlXOrnzTJqc=";
    };
  };
  knap = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "knap";
    src = pkgs.fetchFromGitHub {
      owner = "Mikilio";
      repo = "knap";
      rev = "f7d6e0938cfd832279ef2eda623aeb8341a37b7d";
      hash = "sha256-WN6gmgn6+/ayvTDUFQ2oTUvkqR7taegUroTiLHg7rCs=";
    };
  };

in
{
  config = mkIf (cfg.editor=="nvim"){
    home.file.".config/nvim/lua".source = ./lua;

    programs.bash = {
      initExtra = ''
        export EDITOR="nvim"
        '';

      shellAliases = {
        vi = cmd;
        vim = cmd;
        nvim = cmd;
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
        ltex-ls
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
        {
          plugin = knap;
          config = "require('plugins.knap')";
          type = "lua";
        }
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

#Debug Adapter Protocol
        nvim-dap

#TeXMagic
        {
          plugin = texmagic;
          config = "require('texmagic').setup{}";
          type = "lua";
        }


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
        neomake
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
