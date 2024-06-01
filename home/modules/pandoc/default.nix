{
  lib,
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
          pdf-engine = "xelatex";
          variables = {
            citecolor = "draculapurple";
            filecolor = "draculagreen";
            geometry = "margin=1in";
            header-includes = ["\\usepackage\{${config.home.sessionVariables.XDG_CONFIG_HOME}/pandoc/draculatheme.sty\}"];
            linkcolor = "draculapink";
            toccolor = "draculaorange";
            urlcolor = "draculacyan";
          };
        };
      };
    };

    xdg.configFile = {
      "pandoc/dracula.theme".source = ./dracula.theme;
      "pandoc/draculatheme.sty".source = ./draculatheme.sty;
    };
  };
}
