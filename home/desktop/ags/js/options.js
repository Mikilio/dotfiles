/**
 * An object holding Options that are Variables with cached values.
 *
 * to update an option at runtime simply run
 * ags -r "options.path.to.option.setValue('value')"
 *
 * resetting:
 * ags -r "options.reset()"
 */

import { Option, resetOptions, getValues, apply, getOptions } from './settings/option.js';
import { USER } from 'resource:///com/github/Aylur/ags/utils.js';
import themes from './themes.js';

export default {
    reset: resetOptions,
    values: getValues,
    apply: apply,
    list: getOptions,

    spacing: Option(9),
    padding: Option(8),
    radii: Option(9),

    popover_padding_multiplier: Option(1.4, {
        'category': 'General',
        'note': 'popover-padding: padding × this',
        'type': 'float',
        'unit': '',
    }),

    color: {
        red: Option('#F38BA8', { 'scss': 'red' }),
        green: Option('#A6E3A1', { 'scss': 'green' }),
        yellow: Option('#F9E2AF', { 'scss': 'yellow' }),
        blue: Option('#89B4FA', { 'scss': 'blue' }),
        magenta: Option('#F5C2E7', { 'scss': 'magenta' }),
        teal: Option('#94E2D5', { 'scss': 'teal' }),
        orange: Option('#FAB387', { 'scss': 'orange' }),
    },

    theme: {
        name: Option(themes[0].name, {
            'category': 'exclude',
            'note': 'Name to show as active in quicktoggles',
        }),

        icon: Option(themes[0].icon, {
            'category': 'exclude',
            'note': 'Icon to show as active in quicktoggles',
        }),

        scheme: Option('dark', {
            'enums': ['dark', 'light'],
            'type': 'enum',
            'note': "Color scheme to set on Gtk apps: 'ligth' or 'dark'",
            'title': 'Color Scheme',
            'scss': 'color-scheme',
        }),
        bg: Option('#1E1E2E', {
            'title': 'Background Color',
            'scss': 'bg-color',
        }),
        fg: Option('#FEFEFE', {
            'title': 'Foreground Color',
            'scss': 'fg-color',
        }),

        accent: {
            accent: Option('#B4BEFE', {
                'category': 'Theme',
                'title': 'Accent Color',
                'scss': 'accent',
            }),
            fg: Option('#11111B', {
                'category': 'Theme',
                'title': 'Accent Foreground Color',
                'scss': 'accent-fg',
            }),
            gradient: Option('to right, $accent, lighten($accent, 6%)', {
                'category': 'Theme',
                'title': 'Accent Linear Gradient',
                'scss': 'accent-gradient',
            }),
        },

        widget: {
            bg: Option('$fg-color', {
                'category': 'Theme',
                'title': 'Widget Background Color',
                'scss': '_widget-bg',
            }),
            opacity: Option(94, {
                'category': 'Theme',
                'title': 'Widget Background Opacity',
                'unit': '',
                'scss': 'widget-opacity',
            }),
        },
    },

    border: {
        color: Option('$fg-color', {
            'category': 'Border',
            'title': 'Border Color',
            'scss': '_border-color',
        }),
        opacity: Option(97, {
            'category': 'Border',
            'title': 'Border Opacity',
            'unit': '',
        }),
        width: Option(1, {
            'category': 'Border',
            'title': 'Border Width',
        }),
    },

    hypr: {
        inactive_border: Option('rgba(333333ff)', {
            'category': 'Border',
            'title': 'Border on Inactive Windows',
            'scss': 'exclude',
        }),
        wm_gaps_multiplier: Option(2.4, {
            'category': 'General',
            'scss': 'wm-gaps-multiplier',
            'note': 'wm-gaps: padding × this',
            'type': 'float',
            'unit': '',
        }),
    },

    // TODO: use this on revealers
    transition: Option(200, {
        'category': 'exclude',
        'note': 'Transition time on aminations in ms, e.g on hover',
        'unit': 'ms',
    }),

    font: {
        font: Option('Ubuntu Nerd Font', {
            'type': 'font',
            'title': 'Font',
            'scss': 'font',
        }),
        mono: Option('Mononoki Nerd Font', {
            'title': 'Monospaced Font',
            'scss': 'mono-font',
        }),
        size: Option(13, {
            'scss': 'font-size',
            'unit': 'pt',
        }),
    },

    applauncher: {
        width: Option(500),
        height: Option(500),
        anchor: Option(['top']),
        icon_size: Option(52),
    },

    bar: {
        position: Option('top', {
            'enums': ['top', 'bottom'],
            'type': 'enum',
        }),
        style: Option('normal', {
            'enums': ['floating', 'normal', 'separated'],
            'type': 'enum',
        }),
        flat_buttons: Option(true, { 'scss': 'bar-flat-buttons' }),
        separators: Option(true),
        icon: Option('distro-icon', {
            'note': '"distro-icon" or a single font',
        }),
    },

    battery: {
        show_percentage: Option(true, {
            'persist': true,
            'noReload': false,
            'category': 'exclude',
        }),
        bar: {
            width: Option(70, { 'category': 'Bar' }),
            height: Option(14, { 'category': 'Bar' }),
        },
        low: Option(30, { 'category': 'Bar' }),
        medium: Option(50, { 'category': 'Bar' }),
    },

    desktop: {
        wallpaper: {
            fg: Option('#fff', { 'scss': 'wallpaper-fg' }),
            img: Option(themes[0].options['desktop.wallpaper.img'], {
                'scssFormat': v => `"${v}"`,
                'type': 'img',
            }),
        },
        avatar: Option(`/var/lib/AccountsService/icons/${USER}`, {
            'scssFormat': v => `"${v}"`,
            'type': 'img',
            'note': 'displayed in quicksettings and locksreen',
        }),
        screen_corners: Option(true, { 'scss': 'screen-corners' }),
        clock: {
            enable: Option(true),
            position: Option('center center', {
                'note': 'halign valign',
            }),
        },
        drop_shadow: Option(true, { 'scss': 'drop-shadow' }),
        shadow: Option('rgba(0, 0, 0, .6)', { 'scss': 'shadow' }),
        dock: {
            icon_size: Option(56),
            pinned_apps: Option([
                'firefox',
                'org.wezfurlong.wezterm',
                'discord',
                'spotify',
            ], { 'scss': 'exclude' }),
        },
    },

    notifications: {
        black_list: Option(['Spotify'], { 'note': 'app-name | entry' }),
        position: Option(['top'], { 'note': 'anchor' }),
        width: Option(450),
    },

    dashboard: {
        sys_info_size: Option(70, {
            'category': 'Desktop',
            'scss': 'sys-info-size',
        }),
    },

    mpris: {
        black_list: Option(['Caprine'], {
            'category': 'Bar',
            'title': 'List of blacklisted mpris players',
            'note': 'filters for bus-name, name, identity, entry',
        }),
        preferred: Option('spotify', {
            'category': 'Bar',
            'title': 'Preferred player',
        }),
    },

    workspaces: Option(7, {
        'category': 'Bar',
        'title': 'No. workspaces on bar and overview',
        'note': 'Set it to 0 to make it dynamic',
    }),

    temperature: '/sys/class/hwmon/hwmon2/temp1_input',
    systemFetchInterval: 5000,
    brilloKBD: 'asus::kbd_backlight',
    substitutions: {
        icons: [ ],
        titles: [
            ['com.github.Aylur.ags', 'AGS'],
            ['org.telegram.desktop', 'Telegram'],
            ['com.obsproject.Studio', 'OBS'],
            ['com.github.wwmm.easyeffects', 'Easy Effects'],
            ['org.wezfurlong.wezterm', 'Wezterm'],
            ['com.raggesilver.BlackBox', 'BlackBox'],
            ['firefox', 'Firefox'],
            ['thunar', 'Files'],
            ['libreoffice-writer', 'Writer'],
            ['', 'Desktop'],
        ],
    },
};