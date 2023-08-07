{ pkgs
, ...
}: {

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks = {
      uni = {
        hostname = "lxhalle.in.tum.de";
        user = "ga8etet";
        forwardX11 = true;
      };
    };

    extraConfig = "XAuthLocation ${pkgs.xorg.xauth}/bin/xauth";
  };
}
