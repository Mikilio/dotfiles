{
  pkgs,
  config,
  ...
}: {
  fonts = {
    packages =
      (with pkgs; [
        # icon fonts
        material-symbols

        # All Google fonts
        google-fonts

        # nerdfonts
        (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      ])
      ++ [config.nur.repos.mikilio.ttf-ms-fonts];

    # causes more issues than it solves
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = let
      addAll = builtins.mapAttrs (k: v: ["Symbols Nerd Font"] ++ v ++ ["Noto Color Emoji"]);
    in
      addAll {
        serif = ["Noto Serif"];
        sansSerif = ["Inter"];
        monospace = ["JetBrains Mono"];
        emoji = [];
      };
  };
}
