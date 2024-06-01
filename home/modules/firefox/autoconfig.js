let { classes: Cc, interfaces: Ci, manager: Cm  } = Components;
let Services = globalThis.Services || ChromeUtils.import("resource://gre/modules/Services.jsm").Services;

// focus page instead of adressbar
try {
 Cu.import("resource:///modules/BrowserWindowTracker.jsm");

 Services.obs.addObserver((event) => {
   window = BrowserWindowTracker.getTopWindow();
   window.gBrowser.selectedBrowser.focus();
 }, "browser-open-newtab-start");

} catch(e) { Cu.reportError(e); }

//remove shortcuts
function ConfigJS() { Services.obs.addObserver(this, 'chrome-document-global-created', false); }
ConfigJS.prototype = {
  observe: function (aSubject) { aSubject.addEventListener('DOMContentLoaded', this, {once: true}); },
  handleEvent: function (aEvent) {
    let document = aEvent.originalTarget;
    let window = document.defaultView;
    let location = window.location;
    if (/^(chrome:(?!\/\/(global\/content\/commonDialog|browser\/content\/webext-panels)\.x?html)|about:(?!blank))/i.test(location.href)) {
      if (window._gBrowser) {
        let keys = ["key_close","key_closeWindow", "goHome"];
        for (var i=0; i < keys.length; i++) {
          let keyCommand = window.document.getElementById(keys[i]);
          if (keyCommand != undefined) { 
            keyCommand.removeAttribute("command"); 
            keyCommand.removeAttribute("key"); 
            keyCommand.removeAttribute("modifiers"); 
            keyCommand.removeAttribute("oncommand"); 
            keyCommand.removeAttribute("data-l10n-id"); 
          }
        }
      }
    }
  }
};
if (!Services.appinfo.inSafeMode) { new ConfigJS(); }
