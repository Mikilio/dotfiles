{ config, lib, pkgs, ... }:
with lib;
let
  install_lsp = pkgs.writeShellScriptBin "install_lsp" ''
      #!/bin/bash 
    if [ ! -d ~/.npm-global ]; then  
             mkdir ~/.npm-global
             npm set prefix ~/.npm-global
      else 
             npm set prefix ~/.npm-global
    fi
    npm i -g npm vscode-langservers-extracted vscode-langservers-extracted typescript typescript-language-server bash-language-server
  '';
  cfg = config.modules.nvim;
in
{
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    programs = {

      bash = {
        initExtra = ''
          export EDITOR="nvim"
        '';

        shellAliases = {
          v = "nvim -i NONE";
          nvim = "nvim -i NONE";
        };
      };

      neovim = {
        enable = true;
        vimAlias = true;
        viAlias = true;
        withPython3 = true;
        #-- Plugins --#
        plugins = with pkgs.vimPlugins;[ ];
        #-- --#
      };
    };

    home = {
      packages = with pkgs; [
        #-- LSP --#
        install_lsp
        rnix-lsp
        sumneko-lua-language-server
        gopls
        pyright
        zk
        rust-analyzer
        #-- format --#
        stylua
        black
        nixpkgs-fmt
        rustfmt
        beautysh
        nodePackages.prettier
      ];
    };


    home.file.".config/nvim/init.lua".source = ./init.lua;
    home.file.".config/nvim/lua".source = ./lua;
  };
}
