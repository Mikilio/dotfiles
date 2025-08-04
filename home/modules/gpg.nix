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
      publicKeys = [
        # Pixel Phone
        {
          text = ''
            -----BEGIN PGP PUBLIC KEY BLOCK-----

            mDMEaDsWVRYJKwYBBAHaRw8BAQdApD3MHj/w9S9Jf7ReNqrbZTEn0c3SxO7YY56Y
            as77gba0NUtpbGlhbiBNaW8gKFBpeGVsIFBob25lKSA8b2ZmaWNpYWwubWlraWxp
            b0BnbWFpbC5jb20+iJQEExYKADwWIQRUFuE5m5/BAwXS1OiD6NwvCn7PYgUCaDsW
            VQIbAwUJBaOagAQLCQgHBBUKCQgFFgIDAQACHgUCF4AACgkQg+jcLwp+z2JUxAEA
            qkHWRopx9No8a4bHS8kq7pJqcCFJ3VL/1ebctDPqSPQA/iXbxUr37pRgRWr3zZYJ
            EUAZfLkV3WCsiyv1WgjjTO0PuDgEaDsWVRIKKwYBBAGXVQEFAQEHQHqk0EKIiJxe
            sz4yzMAl0PX/dyhI9swNwxERUlOdzDYvAwEIB4h+BBgWCgAmFiEEVBbhOZufwQMF
            0tTog+jcLwp+z2IFAmg7FlUCGwwFCQWjmoAACgkQg+jcLwp+z2Jn7AD/Xs03Wi/d
            jfouINFUXA7JIw4eWvyT0KsPdRzUlE0OB6UBAIRtFaqwOGdQ/a5nqZqIx6PX65Yl
            0ioE9nW4n7QsbY8B
            =X0C3
            -----END PGP PUBLIC KEY BLOCK-----
          '';
          trust = "ultimate";
        }
      ];
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
      pinentry.package = pkgs.pinentry-gnome3;
      grabKeyboardAndMouse = true;
      sshKeys = ["CC15ADE7A7DCCD12159E32BB32D14EFFEBE8EB5C"];
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
    };
  };
}
