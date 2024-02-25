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
      customPlugs = config.nur.repos.mikilio.overlays.vimPlugins;
    in {
      config = {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
          vimdiffAlias = true;
          extraPackages = with pkgs; [
            #--- LSP ---#
            clang-tools
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
            #Aesthetics
            netrw-nvim
            nvim-web-devicons
            catppuccin-nvim
            indent-blankline-nvim
            rainbow-delimiters-nvim
            lualine-nvim
            gitsigns-nvim
            alpha-nvim
            sunglasses-nvim
            trouble-nvim
            todo-comments-nvim
            # Apps
            knap
            nvim-dap-ui
            # Language Server Protocol
            lsp-zero-nvim
            lspkind-nvim
            nvim-navic
            ltex_extra-nvim
            nvim-lspconfig
            # Auto-Completion
            nvim-cmp
            cmp-buffer
            cmp-path
            cmp_luasnip
            cmp-nvim-lsp
            cmp-nvim-lsp-signature-help
            cmp-nvim-lua

            # Snippets
            luasnip
            # Search and Find
            telescope-media-files-nvim
            telescope-project-nvim
            telescope-zoxide
            telescope-fzy-native-nvim
            telescope-undo-nvim
            telescope-nvim
            #Editing Features
            targets-vim
            nvim-ts-context-commentstring
            comment-nvim
            nvim-surround
            nvim-autopairs
            hop-nvim
            which-key-nvim
            #Integration
            nvim-dap #Debug Adapter Protocol
            texmagic-nvim #TeXMagic
            nvim-treesitter.withAllGrammars #Tree-Sitter
            popup-nvim # Pop-up API from vim
            vim-fugitive #Git
            zoxide-vim # Zoxide
            neovim-session-manager #session management
            wezterm-nvim #wezterm TODO: replace by vim.system on v10
            smart-splits-nvim # better splits
          ];
          extraLuaConfig = let
            luaRequire = module:
              builtins.readFile (builtins.toString
                ./lua
                + "/${module}.lua");
            luaConfig = builtins.concatStringsSep "\n" (map luaRequire [
              "settings"
              "keymaps"
              "alpha"
              "style"
              "lsp"
              "telescope"
              "tools"
              "lualine"
              "git"
            ]);
          in ''
            ${luaConfig}
          '';
        };
      };
    }
)
