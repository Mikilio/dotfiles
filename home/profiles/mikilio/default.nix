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
    # nvim
    neovix
    pass
    pipewire
    productivity
    # rofi
    sioyek
    ssh
    tmux
    xdg
    yazi
    zen
    ./private.nix
  ];
}
