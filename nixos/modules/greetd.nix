{
  lib,
  pkgs,
  config,
  ...
}:
# greetd display manager
let
  greeter = pkgs.writeShellScript "greeter.sh" ''
    ${lib.getExe' pkgs.wlr-randr "wlr-randr"} --output DP-2 --pos -810,0 --transform 90 --scale 1.33334
    ${lib.getExe config.programs.regreet.package}
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
      # background = {
      #   path = theme.wallpaper;
      #   fit = "Cover";
      # };
      GTK = {
        cursor_theme_name = "Bibata-Modern-Classic";
        font_name = "Lexend 12";
        icon_theme_name = "Papirus-Dark";
        theme_name = "Catppuccin-Mocha-Compact-Mauve-Dark";
      };
    };
  };

  services.greetd.settings.default_session = {
    enable = true;
    command = "${lib.getExe pkgs.cage} -s -- ${greeter}";
  };

  services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      ACTION=="add",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl unlock-sessions"
  '';

  # unlock GPG keyring on login
  security.pam = {
    u2f = {
      enable = true;
      cue = true;
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock.u2fAuth = true;
    };
  };
}
