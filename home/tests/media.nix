{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-media";
    module = self.homeModules.media;
    # The module references `pkgs.python3.pkgs.beets-xtractor` and
    # `pkgs.nur.repos.mikilio.essentia`; the repo overlay provides the former
    # and also pulls in the NUR overlay for the latter.
    modules = [
      self.nixosModules.overlays
    ];
    homeModules = [
      {services.mpd.musicDirectory = "~/Music";}
    ];
    testScript =
      loginScript
      + ''
        machine.wait_for_unit("mpd.service", "alice")
        machine.succeed("su - alice -c 'test -f ~/.config/beets/config.yaml'")
        machine.succeed("su - alice -c 'grep -q xtractor ~/.config/beets/config.yaml'")
        machine.succeed("su - alice -c 'test -f ~/.config/newsboat/config'")
      '';
  }
