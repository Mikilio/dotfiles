{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib; let

in {
  config = {
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
})
