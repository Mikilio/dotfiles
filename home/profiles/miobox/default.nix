{
  imports = [
    ../../editors/helix
    ../../editors/nvim
    ../../programs
    ../../programs/games.nix
    ../../programs/dunst.nix
    ../../wayland
    ../../terminals/alacritty.nix
  ];

  home.sessionVariables = {
    GDK_SCALE = "2";
  };
  programs.bash.enable = true;
  targets.genericLinux.enable = true;
}
