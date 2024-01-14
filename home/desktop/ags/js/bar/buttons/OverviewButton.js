import App from 'resource:///com/github/Aylur/ags/app.js';
import PanelButton from '../PanelButton.js';
import FontIcon from '../../misc/FontIcon.js';
import { distroIcon } from '../../variables.js';
import options from '../../options.js';

export default () => PanelButton({
    class_name: 'applauncher',
    window: 'applauncher',
    on_clicked: () => App.toggleWindow('applauncher'),
    content: FontIcon({
        binds: [['icon', options.bar.icon, 'value', v => {
            return v === 'distro-icon' ? distroIcon : v;
        }]],
    }),
});
