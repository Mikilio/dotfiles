{
  config,
  ...
}: {
  programs = {

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

  };
}
