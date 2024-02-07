{
  pkgs,
  config,
  lib,
  self',
  ...
}:
# configuration shared by all hosts
{
  # remove bloat
  documentation.nixos.enable = false;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # saves space
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };

  # pickup pkgs from flake export
  nixpkgs.pkgs = self'.legacyPackages;

  # enable programs
  programs = {
    less.enable = true;

    tmux = {
      enable = true;
      keyMode = "vi";
      clock24 = true;
      baseIndex = 1;
    };
  };

  services = {
    dbus.implementation = "broker";
  };

  # don't ask for password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # don't touch this
  system.stateVersion = lib.mkDefault "23.05";

  time.timeZone = lib.mkDefault "Europe/Berlin";

  # compresses half the ram for use as swap
  zramSwap.enable = true;
}
