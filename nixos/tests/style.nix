{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;

  wallpaper =
    pkgs.runCommand "default.png"
    {
      nativeBuildInputs = [pkgs.imagemagick];
    }
    "convert -size 1920x1080 xc:'#1e1e2e' $out";
in
  mkTest {
    name = "style";
    module = self.nixosModules.style;
    modules = [
      {
        # The repo's assets/ was deprecated on main, so style.nix's wallpaper
        # path no longer exists. Force a generated wallpaper instead.
        stylix.image = lib.mkForce wallpaper;
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.stylix.enable;
            message = "stylix should be enabled";
          }
          {
            assertion = config.stylix.cursor.name == "catppuccin-mocha-dark-cursors";
            message = "stylix cursor should be catppuccin-mocha-dark";
          }
          {
            assertion = config.stylix.polarity == "dark";
            message = "stylix polarity should be dark";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
    '';
  }
