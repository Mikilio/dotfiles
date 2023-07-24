{
  perSystem = {...} @ perSystem: let
    module = {
      config,
      lib,
      pkgs,
      ...
    } @ hm:
      with lib; let
        cfg = config.home.shells;

        shellsModule = types.submodule {
          options = {
            zsh = mkOption {
              type = types.bool;
              default = false;
              description = ''
                This enables zsh as configured by my ./home/shells/zsh.nix
              '';
            };

            nushell = mkOption {
              type = types.bool;
              default = false;
              description = ''
                This enables nushell as configured by my ./home/shells/nushell.nix
              '';
            };

            starship = mkOption {
              type = types.bool;
              default = false;
              description = ''
                This enables starship as configured by ./home/shells/starship.nix
              '';
            };

            joshuto = mkOption {
              type = types.bool;
              default = false;
              description = ''
                This enables a terminal file manager called joshuto
              '';
            };

            editor = mkOption {
              type = types.str;
              default = "nvim";
              description = ''
                Choose your editor
              '';
            };
          };
        };
      in {
        #import all common configurations
        imports = [
          ./zsh.nix
          ./starship.nix
          ./nushell
          ./transient-services.nix
          ./joshuto
          ./git.nix
          ./nix.nix
          ./cli.nix
          ./helix
          ./nvim
        ];

        options = {
          home.shells = mkOption {
            type = shellsModule;
            default = {};
            description = ''
              Shell configuration. Here all shell related configurations will
              be placed
            '';
          };
        };
      };
  in {
    homeManagerModules.shells = module;
  };
}
