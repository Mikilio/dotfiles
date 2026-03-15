{
  config,
  options,
  pkgs,
  lib,
  ...
}: {
  config = {
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

    services = {
      # TODO: this config is not reusable! create some logic here
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
        enableBashIntegration = true;
        pinentry.package = pkgs.pinentry-gnome3;
        grabKeyboardAndMouse = false;
        defaultCacheTtl = 60;
        maxCacheTtl = 120;
      };
    };
    home =
      {
        sessionVariables.GPG_TTY = "$(tty)";
        packages = with pkgs; [
          yubioath-flutter
          yubikey-personalization
          yubikey-manager
          yubico-piv-tool
          gcr
          age-plugin-yubikey
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/storage" = {
          directories = [
            {
              directory = ".yubico";
              mode = "0700";
            }
            {
              directory = ".local/share/gnupg";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
            {
              directory = ".local/share/com.yubico.yubioath";
              mode = "0700";
            }
          ];
        };
      };
  };
}
