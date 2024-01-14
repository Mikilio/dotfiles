import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';
import PanelButton from '../PanelButton.js';
import Gdk from 'gi://Gdk';

const SysTrayItem = item => Widget.Button({
    class_name: 'tray-item',
    child: Widget.Icon({ binds: [['icon', item, 'icon']] }),
    binds: [['tooltip-markup', item, 'tooltip-markup']],
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: (_, event) => item.openMenu(event),
});

export default () => Widget.Box({
    binds: [['children', SystemTray, 'items', i => i.map(SysTrayItem)]],
});
