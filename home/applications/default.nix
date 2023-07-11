{
  inputs,
  default,
  ...
} @ top: {
  perSystem = {
    pkgs,
    lib,
    self',
    inputs',
    ...
  } @ ps: let
    module = {
      config,
      lib,
      pkgs,
      ...
    } @ hm:
      with lib; let
        cfg = config.home;

        listOfBrowsers = [
          "vivaldi"
          "brave"
        ];

        listOfTerminals = [
          "alacritty"
          "foot"
          "kitty"
          "wezterm"
        ];

        listOfReaders = [
          "zathura"
          "sioyek"
        ];

        listOfMisc = [
          "cinny"
        ];

        appsModule = types.submodule {
          options = {
            enable = mkEnableOption "applications";

            media = mkOption {
              type = types.bool;
              default = true;
              description = ''
                this enables all media related things including themed spotify.
                it also includes any form of soundcontrol.
                for more information see media.nix.
              '';
            };

            gui = mkOption {
              type = types.bool;
              default = true;
              description = ''
                this option enables all things related to gui. this includes qt
                and gtk options.
              '';
            };

            games = mkOption {
              type = types.bool;
              default = true;
              description = ''
                this option enables all gaming related things.
              '';
            };

            browser = mkOption {
              type = types.str;
              default = "vivaldi";
              description = ''
                this option is to choose which browser to use.
              '';
            };

            terminal = mkOption {
              type = types.str;
              default = "alacritty";
              description = ''
                This option is to choose which terminal to use.
              '';
            };

            reader = mkOption {
              type = types.str;
              default = "sioyek";
              description = ''
                this option is to choose which pdf-reader to use. please add
                them first to listofreaders.
              '';
            };

            productivity = mkOption {
              type = types.bool;
              default = true;
              description = ''
                this enables a set of productivity tools like obsidian and
                onlyoffice.
              '';
            };

            misc = mkOption {
              type = types.listOf types.str;
              default = [];
              description = ''
                this option adds additional apps. please add the first to
                listofapps.
              '';
            };
          };
        };
      in {
        #import all common configurations
        imports = [
          ./cinny.nix
          ./media.nix
          ./qt.nix
          ./xdg.nix
          ./sioyek.nix
          ./vivaldi.nix
          ./gpg.nix
          ./games.nix
          ./gtk.nix
          ./brave.nix
          ./zathura.nix
          ./alacritty.nix
          ./foot.nix
          ./kitty.nix
          ./wezterm.nix
        ];

        options = {
          home.applications = mkOption {
            type = types.nullOr appsModule;
            default = null;
            description = ''
              Applications configuration. Here all graphical application related configurations will
              be placed
            '';
          };
        };
      };
  in {
    homeManagerModules.applications = module;
  };
}
