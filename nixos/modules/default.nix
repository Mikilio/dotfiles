{ lib, ezModules, ... }: {

  imports = with ezModules; [
    backlight
    bluetooth
    boot
    dbus
    fonts
    fwupd
    gaming
    gnome-services
    greetd
    home-manager
    hyprland
    lanzaboote
    nix
    opengl
    overlays
    pipewire
    security
    spotify
    tailscale
  ];

  documentation.dev.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # saves space
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };

  # enable programs we can't live without
  programs = {
    less.enable = true;

    tmux = {
      enable = true;
      keyMode = "vi";
      clock24 = true;
      baseIndex = 1;
    };
  };

  # don't touch this
  system.stateVersion = lib.mkDefault "23.11";

  time.timeZone = lib.mkDefault "Europe/Berlin";

  # compresses half the ram for use as swap
  zramSwap.enable = true;
}
