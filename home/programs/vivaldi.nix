{  lib, config, pkgs, ... }:
{
  programs.vivaldi = {
      enable = true;
      commandLineArgs = ["--ozone-platform-hint=auto"
      "--ignore-gpu-blocklist" "--enable-gpu-rasterization"
      "--enable-zero-copy" "--disable-gpu-driver-bug-workarounds"
      ];
  };
}
