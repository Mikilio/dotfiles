{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.home.applications;

in {

  config = mkIf (cfg!=null && cfg.browser=="vivaldi"){

    programs.vivaldi = {
      enable = true;
      commandLineArgs = [
        "--disable-gpu-driver-bug-workarounds"
        "--enable-features=WaylandWindowDecorations"
        "--enable-gpu-rasterization" "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        "--ozone-platform=wayland"
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations,CanvasOopRasterization,Vulkan,UseSkiaRenderer,WebContentsForceDark"
      ];
      extensions = [
        {id = "fdjamakpfbbddfjaooikfcpapjohcfmg";}
        {id = "clngdbkpkpeebahjckkjfobafhncgmne";}
      ];
    };
  };
}
