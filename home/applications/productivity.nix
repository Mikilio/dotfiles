{
  pkgs,
  config,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # office
    onlyoffice-bin
    # productivity
    obsidian
    # 3d modelling
    blender
  ];
}
