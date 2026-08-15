{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
in
  mkHomeTest {
    name = "home-impermanence";
    module = self.homeModules.impermanence;
    modules = [
      # The NixOS module auto-imports the home-manager persistence provider
      # (via home-manager.sharedModules); the provider asserts it must not be
      # imported manually.
      inputs.impermanence.nixosModules.impermanence
    ];
    testScript =
      loginScript
      + ''
        # home.persistence directories are wired up as real bind mounts by the
        # NixOS module (not symlinks); the initrd activation creates the
        # persistent mirror (/persistent/<store>/<full-home-path>) and the
        # ephemeral side before the mount units run.
        machine.succeed("mountpoint -q /home/alice/.local/state")
        machine.succeed("mountpoint -q /home/alice/.local/share/containers")
        machine.succeed("findmnt /home/alice/.local/state | grep -q '/persistent/storage'")
        machine.succeed("findmnt /home/alice/.local/share/containers | grep -q '/persistent/cache'")

        # Data written into the ephemeral side is stored in the persistent mirror.
        machine.succeed("su - alice -c 'echo probe > ~/.local/state/impermanence-probe'")
        machine.succeed("test \"$(cat /persistent/storage/home/alice/.local/state/impermanence-probe)\" = probe")
        machine.succeed("su - alice -c 'echo probe > ~/.local/share/containers/impermanence-probe'")
        machine.succeed("test \"$(cat /persistent/cache/home/alice/.local/share/containers/impermanence-probe)\" = probe")
      '';
  }
