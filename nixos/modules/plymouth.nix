_: {
  boot = {

    plymouth = {
      enable = true;
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
