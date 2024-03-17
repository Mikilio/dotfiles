{
  moduleWithSystem,
  inputs,
  self,
  lib,
  config,
  ...
}:
with lib; let
  importModules = builtins.foldl' (mods: mod:
    {
      "${lib.removeSuffix ".nix" (builtins.baseNameOf mod)}" =
        import mod {inherit inputs moduleWithSystem;};
    }
    // mods) {};
in {
  imports = [
    ./profiles
    ./bootstrap.nix
  ];

  flake.homeManagerModules = {
    applications = importModules [
      ./applications/spicetify.nix
      ./applications/media.nix
      ./applications/qt.nix
      ./applications/xdg.nix
      ./applications/sioyek.nix
      ./applications/vivaldi.nix
      ./applications/firefox
      ./applications/gpg.nix
      ./applications/games.nix
      ./applications/gtk.nix
      ./applications/brave.nix
      ./applications/zathura.nix
      ./applications/alacritty.nix
      ./applications/foot.nix
      ./applications/kitty.nix
      ./applications/wezterm
      ./applications/productivity.nix
      ./applications/keepassxc.nix
    ];
    terminal = importModules [
      ./terminal/zsh.nix
      ./terminal/starship.nix
      ./terminal/nushell
      ./terminal/joshuto
      ./terminal/git.nix
      ./terminal/cli.nix
      ./terminal/helix
      ./terminal/nvim
      ./terminal/yazi.nix
      ./terminal/calendar.nix
      ./terminal/ssh
      ./terminal/pass.nix
    ];
    wayland = importModules [
      ./wayland/ags
      ./wayland/waybar
      ./wayland/hyprland
      ./wayland/anyrun.nix
      ./wayland/dunst.nix
      ./wayland/gbar.nix
      ./wayland/pipewire
    ];
  };
}
