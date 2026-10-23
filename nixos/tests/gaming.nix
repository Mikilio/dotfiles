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
      self.nixosModules.home-manager
      self.nixosModules.overlays
      {
        nixpkgs.config.allowUnfreePredicate = _: true;
        home-manager.users.gamer.home.stateVersion = "26.05";
      }
      ({
        config,
        pkgs,
        ...
      }: {
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
          {
            assertion = builtins.any (p: (p.pname or p.name or "") == "fjordlauncher" || builtins.match ".*fjordlauncher.*" (p.pname or p.name or "") != null) (config.home-manager.users.gamer.home.packages or []);
            message = "fjordlauncher should be installed for gaming user";
          }
        ];
      })
    ];
    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("id gamer")
      machine.succeed("command -v steam")
      machine.succeed("command -v gamemoded")
      machine.succeed("command -v gamescope")
      machine.succeed("su - gamer -c 'command -v fjordlauncher'")
    '';
  }
