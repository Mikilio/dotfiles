{
  config,
  pkgs,
  lib,
  ...
}:
with lib; with builtins; let
  cfg = config.home.applications;
  browser = if (isNull cfg) then null else cfg.browser;
in {
  config = mkIf (browser == "vivaldi") {

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
}
