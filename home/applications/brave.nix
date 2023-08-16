{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
in {
  config = mkIf (cfg != null && cfg.browser == "brave") {
    programs.brave = {
      enable = true;
      #            commandLineArgs = ["--enable-features=UseOzonePlatform" "--ozone-platform=wayland"];
      extensions = [
        {id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";} #grammarly
        {id = "iejmieihafhhmjpoblelhbpdgchbckil";} #spellcheck in overleaf
        {id = "phidhnmbkbkbkbknhldmpmnacgicphkf";} #citation management
        {id = "ldipcbpaocekfooobnbcddclnhejkcpn";} #google scholar
        {id = "nplimhmoanghlebhdiboeellhgmgommi";} #tab groups
      ];
    };
  };
}
