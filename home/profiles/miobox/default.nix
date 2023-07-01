{
  imports = [
    ../../editors/helix
    ../../editors/nvim
    ../../programs
    ../../terminals/alacritty.nix
 ];

  home.sessionVariables = {
    GDK_SCALE = "2";
  };
}
