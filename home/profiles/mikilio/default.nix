{ezModules, ...}: {
  imports = with ezModules; [
    anyrun
    cli
    email
    games
    gpg
    git
    ghostty
    hyprland
    impermanence
    media
    nushell
    # nvim
    neovix
    pass
    pipewire
    productivity
    # rofi
    sioyek
    spicetify
    ssh
    starship
    tmux
    transient-services
    xdg
    yazi
    zen
    ./private.nix
  ];
}
