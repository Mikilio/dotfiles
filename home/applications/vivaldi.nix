{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let

in {
  config = {
    home.sessionVariables.BROWSER = "vivaldi";

    programs.vivaldi = {
      enable = true;
      commandLineArgs = [
        "--disable-gpu-driver-bug-workarounds"
        "--enable-features=WaylandWindowDecorations"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--ignore-gpu-blocklist"
        "--ozone-platform=wayland"
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations,CanvasOopRasterization,Vulkan,UseSkiaRenderer"
      ];
      extensions = [
        {id = "oboonakemofpalcgghocfoadofidjkkk";}
        {id = "clngdbkpkpeebahjckkjfobafhncgmne";}
      ];
    };
  };
})
