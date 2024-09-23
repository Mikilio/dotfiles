{
  ezConfigs,
  inputs,
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = with inputs; [
    stylix.homeManagerModules.stylix
  ];

  stylix =
    let
      global = osConfig.stylix;
      palette = ''${lib.getExe pkgs.yq} '.palette | values | join(" ")' ${global.base16Scheme} | tr -d '"' '';
      prism = pkgs.runCommand "prism" { } ''
        mkdir $out
        for WALLPAPER in $(find ${ezConfigs.root}/assets/wallpapers -type f)
        do
          ${pkgs.lutgen}/bin/lutgen apply $WALLPAPER -o $out/$(basename $WALLPAPER) -- ''$(${palette})
        done
      '';
    in
    {
      enable = true;
      inherit (global)
        image
        base16Scheme
        polarity
        cursor
        ;
    };

  home = {
    packages = with pkgs; [
      adwaita-icon-theme
      papirus-icon-theme
    ];
  };

  gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = if (config.stylix.polarity == "dark") then "Papirus-Dark" else "Papirus-Light";
  };
}
