{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      uni = {
        hostname = "lxhalle.in.tum.de";
        user = "mio";
        forwardX11 = true;
        forwardAgent = true;
      };
      dr01 = {
        hostname = "176.9.139.62";
        port = 54022;
        user = "mikilio";
      };
      dr01-root = {
        hostname = "176.9.139.62";
        port = 54022;
        user = "root";
      };
      dr01-rescue = {
        hostname = "176.9.139.62";
        user = "root";
      };
      dr01wg = {
        hostname = "10.10.0.1";
        port = 54022;
        user = "mikilio";
      };
      dr01unlock = {
        hostname = "176.9.139.62";
        user = "root";
        port = 2222;
      };
      dr02unlock = {
        hostname = "88.99.164.24";
        user = "root";
        port = 2222;
      };
      dr02-root = {
        hostname = "88.99.164.24";
        port = 54022;
        user = "root";
      };
      dr02-rescue = {
        hostname = "88.99.164.24";
        user = "root";
        port = 22;
      };
      dr02 = {
        hostname = "88.99.164.24";
        port = 54022;
        user = "mikilio";
      };
      testbed = {
        hostname = "testbed.acn.net.cit.tum.de";
        user = "s12333";
        port = 10022;
      };
     "*.testbed" = {
        hostname = "%h.acn.net.cit.tum.de";
        user = "root";
        proxyJump = "testbed";
        checkHostIP = false;
      };
      "." = {
        hashKnownHosts = true;
        extraOptions = {
          XAuthLocation = "${pkgs.xorg.xauth}/bin/xauth";
          KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521";
        };
      };
    };
  };
}
