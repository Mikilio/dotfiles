{ inputs, pkgs, config, ... }:

{
  home.username = "mikilio";
  home.homeDirectory = "/home/mikilio";

  home.stateVersion = "22.11";
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./nvim
    ./git
    ./brave
    ./vivaldi
    ./zathura
    ./packages
    ./environment
  ];
}
