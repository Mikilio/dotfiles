{  lib, config, pkgs, ... }:
with lib;
let
    cfg = config.modules.vivaldi;
in {
    options.modules.vivaldi = { enable = mkEnableOption "vivaldi"; };
    config = mkIf cfg.enable {

        programs.brave = {
            enable = true;
#            commandLineArgs = ["--enable-features=UseOzonePlatform" "--ozone-platform=wayland"];
            # extensions = [
            #     { id = "kbfnbcaeplbcioakkpcpgfkobkghlhen"; } #grammarly
            #     { id = "iejmieihafhhmjpoblelhbpdgchbckil"; } #spellcheck in overleaf
            #     { id = "phidhnmbkbkbkbknhldmpmnacgicphkf"; } #citation management
            #     { id = "ldipcbpaocekfooobnbcddclnhejkcpn"; } #google scholar

        };
    };
}
