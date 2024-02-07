{ moduleWithSystem
, inputs
, self
, lib
, config
, ...
}:
with lib;

let

  importModules = builtins.foldl' ( mods: mod:
    { 
      "${lib.removeSuffix ".nix" (builtins.baseNameOf mod)}" =
        import mod { inherit inputs moduleWithSystem;};
    } // mods ) {};
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
    shell = importModules [
      ./shells/zsh.nix
      ./shells/starship.nix
      ./shells/nushell
      ./shells/joshuto
      ./shells/git.nix
      ./shells/cli.nix
      ./shells/helix
      ./shells/nvim
    ];
    desktop = importModules [
      ./desktop/ags
      ./desktop/waybar
      ./desktop/anyrun.nix
      ./desktop/dunst.nix
      ./desktop/hyprland.nix
      ./desktop/gbar.nix
      ./desktop/swayidle.nix
      ./desktop/swaylock.nix
      ./desktop/pipewire
    ];
  };
}
