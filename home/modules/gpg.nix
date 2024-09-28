{
  config,
  pkgs,
  ...
}: {
  programs = {
    gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
      settings = {
        use-agent = true;
        personal-cipher-preferences = ["AES256" "AES192" "AES"];
        personal-digest-preferences = ["SHA512" "SHA384" "SHA256"];
        personal-compress-preferences = ["ZLIB" "BZIP2" "ZIP" "Uncompressed"];
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = ["show-uid-validity" "show-unusable-subkeys"];
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        armor = true;
        throw-keyids = true;
        keyserver = "hkps://keys.openpgp.org";
        trust-model = "tofu+pgp";
        verbose = true;
      };
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
  };

  home = {
    sessionVariables.GPG_TTY = "$(tty)";
    packages = with pkgs; [
      yubioath-flutter
      yubikey-personalization
      yubikey-manager
      yubico-piv-tool
    ];
  };

  services = {
    # TODO: this config is not reusable! create some logic here
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      grabKeyboardAndMouse = true;
      sshKeys = ["CC15ADE7A7DCCD12159E32BB32D14EFFEBE8EB5C"];
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
    };
  };
}
