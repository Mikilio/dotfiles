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
