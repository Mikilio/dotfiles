{
  lib,
  pkgs,
  config,
  theme,
  ...
}:
# greetd display manager
let
  greeter = pkgs.writeShellScript "greeter.sh" ''
    ${lib.getExe' pkgs.imv "imv"} -s crop ${theme.wallpaper} &
    ${lib.getExe config.programs.regreet.package}
    kill $(jobs -p)
  '';
  westonConfig = ''
    [core]
    shell=kiosk
    xwayland=false
    backend=drm

    [shell]
    cursor-theme=Bibata-Modern-Classic

    [output]
    name=DP-1
    app-ids=apps.regreet

    [output]
    name=DP-2
    app-ids=imv

    [keyboard]
    numlock-on=true

    [autolaunch]
    path=${greeter}
    watch=true;
  '';

in {
  environment.systemPackages = with pkgs; [
    # theme packages
    (catppuccin-gtk.override {
      accents = ["mauve"];
      size = "compact";
      variant = "mocha";
    })
    bibata-cursors
    papirus-icon-theme
  ];

  environment.etc."xdg/weston/weston.ini".text = westonConfig;

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = theme.wallpaper;
        fit = "Cover";
      };
      GTK = {
        cursor_theme_name = "Bibata-Modern-Classic";
        font_name = "Lexend 12";
        icon_theme_name = "Papirus-Dark";
        theme_name = "Catppuccin-Mocha-Compact-Mauve-dark";
      };
    };
  };

  services.greetd.settings.default_session = {
    enable = true;
    command = "${lib.getExe' pkgs.weston "weston"} > /dev/null 2>&1";
  };

  # unlock GPG keyring on login
  security.pam = {
    u2f = {
      enable = true;
      cue = true;
      authFile = config.sops.secrets.u2f_mappings.path;
    };
    services = {
      login.u2fAuth = true;
      swaylock = {};
    };
  };
}
