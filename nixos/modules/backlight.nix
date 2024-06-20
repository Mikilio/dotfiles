{...}: {
  # smooth backlight control
  hardware.brillo.enable = true;

  services.clight = {
    enable = true;
    settings = {
      verbose = true;
      backlight.disabled = true;
      dpms.disabled = true;
      dimmer.timeouts = [870 270];
      gamma.long_transition = true;
      keyboard.disabled = true;
      screen.disabled = true;
    };
  };
}
