{
  config,
  pkgs,
  self',
  ...
}:
# nix tooling
{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
    cachix
  ];

  sops.secrets.cachix.path = "${config.xdg.configHome}/cachix/cachix.dhall";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
