{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.sioyek;

in {
    options.modules.sioyek = { enable = mkEnableOption "zathura"; };
    config = mkIf cfg.enable {
        programs.sioyek = {
          enable = true;

        };
    };
}
