{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-ai";
    module = self.homeModules.ai;
    # The module's `home.file.herdr-nvim` and its activation link reference
    # `pkgs.herdr-nvim`, which the repo overlay provides (not the nixpkgs
    # fork). The overlay module also pulls in NUR.
    modules = [
      self.nixosModules.overlays
    ];
    testScript =
      loginScript
      + ''
        machine.succeed("su - alice -c 'test -f ~/.config/herdr/config.toml'")
        machine.succeed("su - alice -c 'grep -q auto_switch ~/.config/herdr/config.toml'")
        machine.succeed("su - alice -c 'test -d ~/.config/herdr/plugins/herdr-nvim'")
        machine.succeed("su - alice -c 'readlink ~/.config/herdr/plugins/herdr-nvim | grep -q /nix/store'")
        machine.succeed("su - alice -c 'herdr --version'")
      '';
  }
