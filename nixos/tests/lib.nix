{
  inputs,
  lib,
  pkgs,
}: let
  system = pkgs.stdenv.hostPlatform.system;

  nixosTest = import "${inputs.nixpkgs}/nixos/lib/testing-python.nix" {inherit pkgs system;};

  base = {
    system.stateVersion = "26.05";
    boot.loader.systemd-boot.enable = true;
    networking.firewall.enable = lib.mkForce false;

    # The VM has no hardware to detect, so it runs with a facter report
    # describing the machine: modules that rely on facter detection (bluetooth,
    # fprintd) then see the same devices the machine has.
    hardware.facter.reportPath = ../../fixtures/facter.json;

    # The report describes the machine, not the VM, so facter's derived
    # hardware support stays off: it would be wrong here, and it clashes with
    # the initrd modules the test VM sets itself.
    hardware.facter.enable = lib.mkForce false;
  };

  # Build a NixOS test that imports only `module` (plus the per-test
  # `modules`) so each module is verified in isolation and modules cannot
  # shadow or rescue each other.
  mkTest = {
    name,
    module,
    modules ? [],
    testScript,
    meta ? {},
  }:
    nixosTest.runTest {
      inherit name testScript meta;
      nodes.machine = {...}: {
        imports =
          [
            module
            {config = base;}
          ]
          ++ modules;
      };
    };
in {
  inherit mkTest nixosTest;
}
