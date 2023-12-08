{ inputs, ... }@fp:
{ pkgs, ... }:
{
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = with pkgs; [
    sassc
    (python311.withPackages (p: [ p.python-pam ]))
  ];

  programs.ags = {
    enable = true;
    configDir = ./.;
    extraPackages = [ pkgs.libsoup_3 ];
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "sh -c 'ags -b hypr' > log.txt"
    ];
  };
}
