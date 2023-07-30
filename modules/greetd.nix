{
  lib,
  pkgs,
  config,
  default,
  ...
}:
# greetd display manager
let
  greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''

    exec ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

    output * background ${default.wallpaper} fill

    input * {
      xkb_numlock enabled
    }
    seat seat0 xcursor_theme Bibata-Modern-Classic 24
    xwayland disable

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    exec "${lib.getExe config.programs.regreet.package} -l debug; swaymsg exit"
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

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = default.wallpaper;
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
    command = "${config.programs.sway.package}/bin/sway --config ${greetdSwayConfig}";
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
      swaylock.text = ''
        auth include login
      '';
    };
  };
}
