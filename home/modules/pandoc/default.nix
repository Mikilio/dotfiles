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
          highlight-style = "${config.home.sessionVariables.XDG_CONFIG_HOME}/pandoc/dracula.theme";
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
              "\\usepackage\{${config.home.sessionVariables.XDG_CONFIG_HOME}/pandoc/draculatheme\}"
              ''
                \directlua{
                  luaotfload.add_fallback("noto-sans", { "Noto Sans CJK JP:mode=harf;", "Noto Color Emoji:mode=harf;" })
                  luaotfload.add_fallback("noto-serif", { "Noto Serif CJK JP:mode=harf;", "Noto Color Emoji:mode=harf;" })
                  luaotfload.add_fallback("noto-mono", { "Noto Sans Mono CJK JP:mode=harf;", , "Noto Color Emoji:mode=harf;" })
                }
                \setmainfont{DejaVuSerif}[RawFeature={fallback=noto-serif}]
                \setsansfont{DejaVuSans}[RawFeature={fallback=noto-sans}]
                \setmonofont{DejaVuMono}[RawFeature={fallback=noto-mono}]
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

    home.packages = [pkgs.noto-fonts-cjk-sans-static];

    xdg.configFile = {
      "pandoc/dracula.theme".source = ./dracula.theme;
      "pandoc/draculatheme.sty".source = ./draculatheme.sty;
    };
  };
}
