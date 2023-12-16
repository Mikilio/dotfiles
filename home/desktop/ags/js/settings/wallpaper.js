import options from '../options.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { dependencies } from '../utils.js';

export function initWallpaper() {
    if (dependencies(['hyprpaper'])) {
        exec('hyprctl dispatch exec hyprpaper');

        // options.desktop.wallpaper.img.connect('changed', wallpaper);
    }
}

export function wallpaper() {
    if (!dependencies(['hyprpaper']))
        return;

    execAsync([
        'echo', 'Not yet implemented!'
    ]).catch(err => console.error(err));
}
