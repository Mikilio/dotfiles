{...}: {

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks = {
      hostname = "lxhalle.in.tum.de";
      user = "ga8etet";
      forwardX11 = true;
    };
  };
}
