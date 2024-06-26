{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks = {
      uni = {
        hostname = "lxhalle.in.tum.de";
        user = "mio";
        forwardX11 = true;
        forwardAgent = true;
      };
    };

    extraConfig = ''
      XAuthLocation ${pkgs.xorg.xauth}/bin/xauth
      KexAlgorithms curve25519-sha256
    '';
  };
}
