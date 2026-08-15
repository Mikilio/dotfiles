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

  # Every home test boots a NixOS VM, logs alice in on a virtual console and
  # waits for her home-manager user session (default.target) so user services
  # are up before the per-module assertions run.
  loginScript = ''
    machine.wait_for_unit("multi-user.target")
    with subtest("Log in as alice on a virtual console"):
        machine.wait_until_tty_matches("1", "login: ")
        machine.send_chars("alice\n")
        machine.wait_until_tty_matches("1", "Password: ")
        machine.send_chars("foobar\n")
        machine.wait_until_succeeds("pgrep -u alice bash")
    machine.wait_for_unit("default.target", "alice")
  '';

  # The hyprland home module sets wayland.windowManager.hyprland.package =
  # null (UWSM provides the binary on the real system), but the home-manager
  # config generator needs a real package to pick the config syntax version.
  hyprlandPackageAccommodation = {
    lib,
    pkgs,
    ...
  }: {
    wayland.windowManager.hyprland.package = lib.mkForce pkgs.hyprland;
  };

  # The hyprland home module asserts i18n.inputMethod.fcitx5.imList has at
  # least two entries; any test importing hyprland (directly or via dms/anyrun/
  # walker) must provide it.
  hyprlandAccommodation = {
    i18n.inputMethod.fcitx5.imList = ["keyboard-us" "keyboard-ua"];
  };

  # Modules referencing pkgs.nur (firefox, floorp, zen, yazi, zus, media)
  # need the NUR overlay on the system pkgs that useGlobalPkgs exposes.
  nurAccommodation = {nixpkgs.overlays = [inputs.nur.overlays.default];};

  # Firefox addons carry unfree licenses (languagetool, wikwand, ...).
  allowUnfree = {nixpkgs.config.allowUnfreePredicate = _: true;};

  # `xdg.portal.enable = true` (set by the xdg and hyprland home modules)
  # asserts an HM-level portal implementation, and with useUserPackages a
  # NixOS-level one plus environment.pathsToLink. The two modules below
  # satisfy those; use the HM one in `homeModules` and the system one in
  # `modules`.
  xdgPortalHmAccommodation = {pkgs, ...}: {
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  xdgPortalSystemAccommodation = {pkgs, ...}: {
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
  };

  mkHomeTest = {
    name,
    module,
    modules ? [],
    homeModules ? [],
    testScript,
    meta ? {},
  }:
    nixosTest.runTest {
      inherit name testScript meta;
      nodes.machine = {...}: {
        imports =
          [
            inputs.home-manager.nixosModules.home-manager
            {config = base;}
          ]
          ++ modules;

        users.users.alice = {
          isNormalUser = true;
          group = "users";
          password = "foobar";
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          users.alice = {
            home.stateVersion = "26.05";
            imports = [module] ++ homeModules;
          };
        };
      };
    };
in {
  inherit mkHomeTest loginScript hyprlandAccommodation hyprlandPackageAccommodation nurAccommodation allowUnfree xdgPortalHmAccommodation xdgPortalSystemAccommodation;
}
