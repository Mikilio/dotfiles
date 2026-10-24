{
  inputs,
  pkgs,
  lib,
  options,
  config,
  ...
}: {
  imports = [
    inputs.dux-plugin-registry.nixosModules.default
    inputs.dcal.nixosModules.default
    inputs.dank-greeter.nixosModules.default
  ];

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        dcal = config.programs.dank-calendar.package;
      })
    ];

    programs = {
      dsearch = {
        enable = true;
        systemd.enable = true;
      };
      dank-calendar = {
        enable = true;
        systemd.enable = true;
      };
      dux-shell = {
        enable = true;
        package = inputs.dux.packages.${pkgs.stdenv.hostPlatform.system}.default;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        excludePackages = [pkgs.cava];
        plugins = {
          dockerManager.enable = true;
          commandRunner.enable = true;
          emojiLauncher.enable = true;
          nixPackageRunner.enable = true;
          calculator.enable = true;
          dankGifSearch.enable = true;
          dankbarPinentry.enable = true;
        };
      };
      dux-greeter = {
        enable = true;
        compositor.name = "hyprland";
        # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
        configHome = lib.mkIf (options?home-manager && (builtins.attrNames config.home-manager.users) != []) "/home/${
          builtins.head (builtins.attrNames config.home-manager.users)
        }";
      };
    };
  };
}
