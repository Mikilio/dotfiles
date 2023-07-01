{  lib, config, pkgs, ... }:
{

        programs.brave = {
            enable = true;
#            commandLineArgs = ["--enable-features=UseOzonePlatform" "--ozone-platform=wayland"];
            extensions = [
                { id = "kbfnbcaeplbcioakkpcpgfkobkghlhen"; } #grammarly
                { id = "iejmieihafhhmjpoblelhbpdgchbckil"; } #spellcheck in overleaf
                { id = "phidhnmbkbkbkbknhldmpmnacgicphkf"; } #citation management
                { id = "ldipcbpaocekfooobnbcddclnhejkcpn"; } #google scholar
                { id = "nplimhmoanghlebhdiboeellhgmgommi"; } #tab groups
            ];
        };
    };
}
