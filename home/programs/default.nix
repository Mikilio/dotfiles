{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../shell/nix.nix
    ../terminals/foot.nix
    ./cinny.nix
    ./files
    ./media.nix
    ./git.nix
    ./gtk.nix
    ./packages.nix
    ./qt.nix
    ./spicetify.nix
    ./xdg.nix
    ./sioyek.nix
  ];

  programs = {
    vivaldi = {
      enable = true;
      commandLineArgs = ["--ozone-platform-hint=auto"
      "--ignore-gpu-blocklist" "--enable-gpu-rasterization"
      "--enable-zero-copy" "--disable-gpu-driver-bug-workarounds"
      ];
    };

    gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
      sshKeys = ["73D1C4271E8C508E1E55259660C94BE828B07738"];
    };

    # keepassxc.enable = true;
    syncthing.enable = true;
  };
}
