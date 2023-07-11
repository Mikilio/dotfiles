{config, ...}: {
  programs = {
    gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };

  #integration with pam services (unlock gpg after login)
  home.file.".pam-gnupg".text = ''
    947AD9A76E3CC264849444CC4A2A650F9E76B5FF
    BAF2341BD88A9E24A39A102122D699162F301F57
    962C29E85C5026E104466143BA6CE4D7F95B81A9
  '';

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
      sshKeys = ["962C29E85C5026E104466143BA6CE4D7F95B81A9"];
      defaultCacheTtl = 54000;
      maxCacheTtl = 54000;
      extraConfig = ''
        allow-preset-passphrase
      '';
    };
  };
}
