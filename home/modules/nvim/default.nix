{
  config,
  pkgs,
  ...
}: let
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
        nodePackages.typescript-language-server
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

      plugins = with (pkgs.vimPlugins.extend customPlugs); [
        #Aesthetics
        netrw-nvim
        nvim-web-devicons
        catppuccin-nvim
        indent-blankline-nvim
        rainbow-delimiters-nvim
        lualine-nvim
        alpha-nvim
        sunglasses-nvim
        trouble-nvim
        todo-comments-nvim
        dressing-nvim
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
        flash-nvim
        which-key-nvim
        #Integration
        nvim-dap #Debug Adapter Protocol
        texmagic-nvim #TeXMagic
        nvim-treesitter.withAllGrammars #Tree-Sitter
        popup-nvim # Pop-up API from vim
        zoxide-vim # Zoxide
        gitsigns-nvim # Git
        persistence-nvim #session management
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
