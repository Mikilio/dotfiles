{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkTest;
in
  mkTest {
    name = "gaming";
    module = self.nixosModules.gaming;
    modules = [
      {
        nixpkgs.config.allowUnfreePredicate = _: true;
      }
      ({config, ...}: {
        assertions = [
          {
            assertion = config.programs.steam.enable;
            message = "steam should be enabled";
          }
          {
            assertion = config.programs.gamescope.capSysNice;
            message = "gamescope should allow sysnice";
          }
          {
            assertion = config.programs.gamemode.enable;
            message = "gamemode should be enabled";
          }
          {
            assertion = config.gaming.user == "gamer";
            message = "gaming user should default to gamer";
          }
          {
            assertion = config.users.users ? gamer;
            message = "gaming user should be created";
          }
          {
            assertion = config.hardware.steam-hardware.enable;
            message = "steam-hardware should be enabled";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("id gamer")
    '';
  }
