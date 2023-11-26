{ inputs'}:
{
  lib,
  pkgs,
  config,
  theme,
  ...
}:
with lib; let
  cfg = config.preferences.desktop.compositor;
  defaultHyprlandPackage = inputs'.hyprland.packages.default.override {
    enableXWayland = true;
  };
  environment = {
    GDK_BACKEND="wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = 1;
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };
in {
  imports = [
    ./config.nix
  ];

  config = mkIf (cfg == "hyprland") {
    home =  {
      sessionVariables = environment;

      packages = with pkgs; [
        xorg.xprop # get properties from XWayland
        xorg.xauth # to enable ssh Xforwarding
        hyprpaper
        inputs'.hyprland-contrib.packages.grimblast
      ];
    };

    xdg.configFile = let
      wallpapers = "${config.xdg.userDirs.pictures}/wallpapers";
      portrait = "${wallpapers}/portrait";
      landscape = "${wallpapers}/landscape";
    in {
      "Hyprland-xdg-terminals.list".text = "";
      "hypr/hyprpaper.conf".text = ''
        preload = ${portrait}/default.jpg
        preload = ${landscape}/default.jpg

        wallpaper = DP-1, ${landscape}/default.jpg

        wallpaper = DP-2, ${portrait}/default.jpg
      '';
    };

    # enable hyprland
    wayland.windowManager.hyprland = {
      enable = true;
    };

    systemd.user = {

      sessionVariables = environment // {
        PATH = "${config.home.homeDirectory}/.nix-profile/bin" +
          ":${getBin pkgs.coreutils}/bin";
      };

      targets = {
        hyprland-session = {
          Unit = {
            Wants = [ "xdg-desktop-autostart.target" ];
          };
        };
      };
      services = {
        xdg-desktop-portal-hyprland = {
          Unit = {
            Description = "Portal service (Hyprland implementation)";
            ConditionEnvironment = "WAYLAND_DISPLAY";
            PartOf = "graphical-session.target";
          };
          Service = {
            Type = "dbus";
            BusName = "org.freedesktop.impl.portal.desktop.hyprland";
            ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
            Restart = "on-failure";
            Slice = "session.slice";
          };
        };
      };
    };
  };
}
