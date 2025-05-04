{
  lib,
  inputs,
  ezModules,
  ...
}: {
  imports =
    (with ezModules; [
      networking
      security
      home-manager
      nix
      overlays
      tailscale
    ])
    ++ [
      inputs.nur.modules.nixos.default
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

  users.mutableUsers = false;
  users.users.root.hashedPassword = "!";

  # don't touch this
  system.stateVersion = lib.mkDefault "24.11";

  time.timeZone = "Europe/Berlin";
}
