{config, ...}: {
  programs.rofi = let
    inherit (config.lib.formats.rasi) mkLiteral;
  in {
    enable = true;

    extraConfig = {
      modi = mkLiteral "drun,run,filebrowser,window";
      show-icons = true;
      icon-theme = mkLiteral "Papirus";
      parse-hosts = true;
      normalize-match = true;

      drun = {
        parse-user = true;
        parse-system = true;
        fallback-icon = mkLiteral "application-x-addon";
      };

      run = {
        fallback-icon = mkLiteral "application-x-addon";
      };

      window-match-fields = mkLiteral "title,class,role,name,desktop";
      window-format = mkLiteral "{w} - {c} - {t:0}";

      display-window = mkLiteral "Windows";
      display-windowcd = mkLiteral "Window CD";
      display-run = mkLiteral "Run";
      display-ssh = mkLiteral "SSH";
      display-drun = mkLiteral "Apps";
      display-combi = mkLiteral "Combi";
      display-keys = mkLiteral "Keys";
      display-filebrowser = mkLiteral "Files";
    };
  };
}
