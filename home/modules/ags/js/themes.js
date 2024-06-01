/**
 * A Theme is a set of options that will be applied
 * ontop of the default values. see options.js for possible options
 */
import { Theme, WP, lightColors } from './settings/theme.js';

export default [
    Theme({
        name: 'Catppuccin',
        icon: '󰄛',
        "spacing": 9,
        "padding": 8,
        "radii": 9,
        "popover_padding_multiplier": 1.4,
        "color.red": "#F38BA8",
        "color.green": "#A6E3A1",
        "color.yellow": "#F9E2AF",
        "color.blue": "#89B4FA",
        "color.magenta": "#F5C2E7",
        "color.teal": "#94E2D5",
        "color.orange": "#FAB387",
        "theme.scheme": "dark",
        "theme.bg": "#1E1E2E",
        "theme.fg": "#FEFEFE",
        "theme.accent.accent": "#B4BEFE",
        "theme.accent.fg": "#11111B",
        "theme.accent.gradient": "to right, $accent, lighten($accent, 6%)",
        "theme.widget.bg": "$fg-color",
        "theme.widget.opacity": 94,
        "border.color": "$fg-color",
        "border.opacity": 97,
        "border.width": 1,
        "hypr.inactive_border": "rgba(333333ff)",
        "hypr.wm_gaps_multiplier": 2.4,
        "font.font": "Ubuntu Nerd Font",
        "font.mono": "Mononoki Nerd Font",
        "font.size": 13,
        "applauncher.width": 500,
        "applauncher.height": 500,
        "applauncher.anchor": [
          "top"
        ],
        "applauncher.icon_size": 52,
        "bar.position": "top",
        "bar.style": "normal",
        "bar.flat_buttons": true,
        "bar.separators": true,
        "bar.icon": "distro-icon",
        "battery.bar.width": 70,
        "battery.bar.height": 14,
        "battery.low": 30,
        "battery.medium": 50,
        "desktop.wallpaper.fg": "#fff",
        "desktop.wallpaper.img": "",
        "desktop.avatar": "",
        "desktop.screen_corners": true,
        "desktop.clock.enable": false,
        "desktop.clock.position": "center center",
        "desktop.drop_shadow": true,
        "desktop.shadow": "rgba(0, 0, 0, .6)",
        "desktop.dock.icon_size": 56,
        "desktop.dock.pinned_apps": [
          "firefox",
          "org.wezfurlong.wezterm",
          "discord",
          "spotify"
        ],
        "notifications.black_list": [
          "Spotify"
        ],
        "notifications.position": [
          "top"
        ],
        "notifications.width": 450,
        "dashboard.sys_info_size": 70,
        "mpris.black_list": [
          "Caprine"
        ],
        "mpris.preferred": "spotify",
        "workspaces": 7
      }),
];
