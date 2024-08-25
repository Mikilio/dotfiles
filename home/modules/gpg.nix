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

  #integration with pam services (unlock gpg after login)
  home.file.".pam-gnupg".text = ''
    ${config.programs.gpg.homedir}
    AFF0BF78824FE6E2C8B23A035EF592F4B0A189DE
    833FE074875A67DB3215AE16C1DCCCAD084FAB6C
    CC15ADE7A7DCCD12159E32BB32D14EFFEBE8EB5C
  '';

  home = {
    sessionVariables.GPG_TTY = "$(tty)";
    packages = with pkgs; [
      yubioath-flutter
      yubikey-personalization
      yubikey-manager
      yubico-piv-tool
    ];
  };

  pam.yubico.authorizedYubiKeys.ids = ["cccccbhkevjb"];

  services = {
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
