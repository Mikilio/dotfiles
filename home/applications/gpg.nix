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
      sshKeys = [
        "962C29E85C5026E104466143BA6CE4D7F95B81A9"
        "947AD9A76E3CC264849444CC4A2A650F9E76B5FF"
      ];
    };
  };
}
