{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.git;

in {
    options.modules.git = { enable = mkEnableOption "git"; };
    config = mkIf cfg.enable {
        programs.git = {
            enable = true;
            userName = "Mikilio";
            userEmail = "kilian.mio@tum.de";
            delta.enable = true;
        };
    };
}
