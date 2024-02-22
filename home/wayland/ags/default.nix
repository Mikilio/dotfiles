{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.ags.homeManagerModules.default];

    home.packages = with pkgs; [
      sassc
      inotify-tools
      libnotify
      imagemagick_light
      nerdfonts
      (python311.withPackages (p: [p.python-pam]))
    ];

    programs.ags = {
      enable = true;
      configDir = ./.;
      extraPackages = with pkgs; [libsoup_3];
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "sh -c 'ags -b hypr 2>&1 | tee ./.cache/ags.log'"
      ];
    };
  }
)
