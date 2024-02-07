import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import options from '../options.js';
import { dependencies } from '../utils.js';

// const KBD = options.brightnessctlKBD;

class Brightness extends Service {
    static {
        Service.register(this, {}, {
            'screen': ['float', 'rw'],
        });
    }

    #screen = 0;

    get screen() { return this.#screen; }

    set screen(percent) {
        if (!dependencies(['brillo']))
            return;

        if (percent < 0)
            percent = 0;

        if (percent > 1)
            percent = 1;

        Utils.execAsync(`brillo -e -q -u 300000 -S ${percent * 100}% `)
            .then(() => {
                this.#screen = percent;
                this.changed('screen');
            })
            .catch(console.error);
    }

    constructor() {
        super();

        if (dependencies(['brillo'])) {
            this.#screen = Number(Utils.exec('brillo'));
        }
    }
}


export default new Brightness();
