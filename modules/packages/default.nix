{ pkgs, lib, config, ... }:

with lib;
let cfg = 
    config.modules.packages;

in {
    options.modules.packages = { enable = mkEnableOption "packages"; };
    config = mkIf cfg.enable {
    	home.packages = with pkgs; [
            ripgrep zk clang
            htop fzf unzip
            git python3 lua 
        ];
    };
}
