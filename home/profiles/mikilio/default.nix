{ezModules, ...}: {
  imports = with ezModules; [
    anyrun
    cli
    email
    floorp
    gpg
    git
    ghostty
    hyprland
    media
    nushell
    # nvim
    neovix
    pass
    pipewire
    productivity
    private
    sioyek
    spicetify
    ssh
    starship
    theming
    tmux
    transient-services
    xdg
    yazi
    zen
    zus
  ];
}
