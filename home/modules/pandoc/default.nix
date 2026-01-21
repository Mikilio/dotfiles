{
  pkgs,
  config,
  ...
}: {
  config = {
    programs = {
      pandoc = {
        enable = true;
        defaults = {
          highlight-style = "${config.xdg.configHome}/pandoc/dracula.theme";
          metadata = {
            author = "Kilian Mio";
            keywords = ["Dracula theme"];
          };
          pdf-engine = "lualatex";
          variables = {
            citecolor = "draculapurple";
            filecolor = "draculagreen";
            geometry = "margin=1in";
            header-includes = [
              ''
                \usepackage{${config.xdg.configHome}/pandoc/draculatheme}
              ''
              ''
                \directlua{
                  luaotfload.add_fallback("emoji-sans", { "Noto Sans CJK JP:mode=harf;", "Noto Color Emoji:mode=harf;" })
                  luaotfload.add_fallback("emoji-serif", { "Noto Serif CJK JP:mode=harf;", "Noto Color Emoji:mode=harf;" })
                  luaotfload.add_fallback("emoji-mono", { "Noto Sans Mono CJK JP:mode=harf;", "Noto Color Emoji:mode=harf;" })
                }
                \setmainfont{DejaVuSerif}[RawFeature={fallback=emoji-serif}]
                \setsansfont{DejaVuSans}[RawFeature={fallback=emoji-sans}]
                \setmonofont{DejaVuSansMono}[RawFeature={fallback=emoji-mono}]
              ''
            ];
            linkcolor = "draculapink";
            toccolor = "draculaorange";
            urlcolor = "draculacyan";
          };
        };
      };
    };

    programs.texlive = {
      enable = true;
      extraPackages = tpkgs: {
        inherit (tpkgs) scheme-full;
      };
    };

    home.packages = with pkgs; [
      noto-fonts-cjk-sans-static
      noto-fonts-cjk-serif-static
    ];

    xdg.configFile = {
      "pandoc/dracula.theme".source = ./dracula.theme;
      "pandoc/draculatheme.sty".source = ./draculatheme.sty;
    };
  };
}
