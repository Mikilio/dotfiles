{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.dux-plugin-registry.nixosModules.default
    inputs.dcal.nixosModules.default
  ];

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        dcal = config.programs.dank-calendar.package;
      })
    ];

    programs = {
      dux-search = {
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
    };

    services.displayManager.dux-greeter = {
      enable = true;
      package = inputs.dux-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}
