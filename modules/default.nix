{ inputs, pkgs, config, ... }:

{
  home.username = "mikilio";
  home.homeDirectory = "/home/mikilio";

  home.stateVersion = "21.05";

  #Workaround
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./nvim
    ./git
    ./brave
    ./zathura
    ./packages
    ./environment/gnome.nix
  ];
}
