{
  config,
  pkgs,
  options,
  lib,
  ...
}: {
  config =
    {
      warnings =
        lib.optional
        (lib.all (name: name == ".") (builtins.attrNames config.programs.ssh.settings))
        ''
          No SSH hosts are configured, so ssh has no aliases to offer. Declaring
          your hosts in your profile is recommended.
        '';

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.lima/*/ssh.config"
        ];
        settings = {
          "." = {
            HashKnownHosts = true;
            XAuthLocation = "${pkgs.xauth}/bin/xauth";
            KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521";
          };
        };
      };
    }
    // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
    {
      # Persisted as a directory on purpose: a per-file bind mount for
      # known_hosts makes ssh's link(2)-based host key rotation fail with
      # "Invalid cross-device link".
      home.persistence."/persistent/storage" = {
        directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
      };
    };
}
