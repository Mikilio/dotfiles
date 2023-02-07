{ lib, config, ... }:

with lib;
let
  cfg = config.modules.environment;
in {
  config = mkIf (cfg.profile == "gnome") {
    home = {
        sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "brave";
        TERMINAL = "gnome-terminal";
        GTK_IM_MODULE = "ibus";
        QT_IM_MODULE = "ibus";
        XMODIFIERS = "@im=ibus";
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_SCALE_FACTOR = "1";
        MOZ_ENABLE_WAYLAND = "1";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
        #GBM
        #GBM_BACKEND = "nvidia-drm";
        #CLUTTER_BACKEND = "wayland";
        #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
        #LIBVA_DRIVER_NAME = "nvidia";
        #vulkan
        #WLR_RENDERER="vulkan";
        #__NV_PRIME_RENDER_OFFLOAD="1";

        XDG_CURRENT_DESKTOP = "GNOME";
        XDG_SESSION_DESKTOP = "GNOME";
        XDG_CACHE_HOME = "\${HOME}/.cache";
        XDG_CONFIG_HOME = "\${HOME}/.config";
        XDG_BIN_HOME = "\${HOME}/.local/bin";
        XDG_DATA_HOME = "\${HOME}/.local/share";
        };
        sessionPath = [
        "$HOME/.local/bin"
        ];
    };
  };
}
