{...}: {
  config = {
    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;

    home.stateVersion = "23.11";
  };
}
