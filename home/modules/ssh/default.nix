{
  pkgs,
  options,
  lib,
  ...
}: {
  config =
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.lima/*/ssh.config"
        ];
        settings = {
          uni = {
            HostName = "lxhalle.in.tum.de";
            User = "mio";
            ForwardX11 = true;
            ForwardAgent = true;
          };
          dr01 = {
            HostName = "176.9.139.62";
            Port = 54022;
            User = "mikilio";
          };
          dr01-root = {
            HostName = "176.9.139.62";
            Port = 54022;
            User = "root";
          };
          dr01-rescue = {
            HostName = "176.9.139.62";
            User = "root";
          };
          dr01wg = {
            HostName = "10.10.0.1";
            Port = 54022;
            User = "mikilio";
          };
          dr01unlock = {
            HostName = "176.9.139.62";
            User = "root";
            Port = 2222;
          };
          dr02unlock = {
            HostName = "88.99.164.24";
            User = "root";
            Port = 2222;
          };
          dr02-root = {
            HostName = "88.99.164.24";
            Port = 54022;
            User = "root";
          };
          dr02-rescue = {
            HostName = "88.99.164.24";
            User = "root";
            Port = 22;
          };
          dr02 = {
            HostName = "88.99.164.24";
            Port = 54022;
            User = "mikilio";
          };
          testbed = {
            HostName = "testbed.acn.net.cit.tum.de";
            User = "s12333";
            Port = 10022;
          };
          "*.testbed" = {
            HostName = "%h.acn.net.cit.tum.de";
            User = "root";
            ProxyJump = "testbed";
            CheckHostIP = false;
          };
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
      home.persistence."/persistent/storage" = {
        files = [
          {
            file = ".ssh/known_hosts";
            parentDirectory = {mode = "0700";};
          }
        ];
      };
    };
}
