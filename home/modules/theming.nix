{
  ezConfigs,
  inputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  imports = with inputs; [
    stylix.homeModules.stylix
  ];

  stylix = let
    global = osConfig.stylix;
    palette = ''${lib.getExe pkgs.yq} '.palette | values | join(" ")' ${global.base16Scheme} | tr -d '"' '';
    prism = pkgs.runCommand "prism" {} ''
      mkdir $out
      for WALLPAPER in $(find ${ezConfigs.root}/assets/wallpapers -type f)
      do
        ${pkgs.lutgen}/bin/lutgen apply $WALLPAPER -o $out/$(basename $WALLPAPER) -- ''$(${palette})
      done
    '';
  in {
    enable = true;
    overlays.enable = lib.mkForce false;
    targets = {
      kde.enable = false;
    };
    inherit
      (global)
      image
      base16Scheme
      polarity
      cursor
      icons
      ;
  };
}
