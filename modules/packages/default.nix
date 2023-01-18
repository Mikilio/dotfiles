{ pkgs, lib, config, ... }:

with lib;
let cfg =
    config.modules.packages;

in {
    options.modules.packages = { enable = mkEnableOption "packages"; };
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            ripgrep fd zk clang
            htop fzf unzip
            git python3 lua
            xclip texlive.combined.scheme-full
        ];
    };
}
