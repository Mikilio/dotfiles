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
    stylix.homeModules.stylix
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

  xdg.configFile =
    let
      variant = "mocha";
      accent = "mauve";
      kvantumThemePackage = pkgs.catppuccin-kvantum.override {
        inherit variant accent;
      };

    in
    {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=catppuccin-${variant}-${accent}
      '';

      # The important bit is here, links the theme directory from the package to a directory under `~/.config`
      # where Kvantum should find it.
      "Kvantum/catppuccin-${variant}-${accent}".source =
        "${kvantumThemePackage}/share/Kvantum/catppuccin-${variant}-${accent}";
    };

}
