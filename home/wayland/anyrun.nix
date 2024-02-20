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
    imports = [
      inputs.anyrun.homeManagerModules.default
    ];

    config.programs.anyrun = {
      enable = true;

      config = {
        plugins = with inputs'.anyrun.packages; [
          applications
          randr
          rink
          shell
          symbols
          translate
        ];
      };

      extraCss = ''
        * {
          transition: 200ms ease;
          font-family: Lexend;
          font-size: 1.3rem;
        }

        #window,
        #match,
        #entry,
        #plugin,
        #main {
          background: transparent;
        }

        #match:selected {
          background: rgba(203, 166, 247, 0.7);
        }

        #match {
          padding: 3px;
          border-radius: 16px;
        }

        #entry, #plugin:hover {
          border-radius: 16px;
        }

        box#main {
          background: rgba(30, 30, 46, 0.7);
          border: 1px solid #28283d;
          border-radius: 24px;
          padding: 8px;
        }
      '';

      extraConfigFiles."applications.ron".text = ''
        Config(
          // Also show the Desktop Actions defined in the desktop files, e.g. "New Window" from LibreWolf
          desktop_actions: false,
          max_entries: 5,
          // The terminal used for running terminal based desktop entries, if left as `None` a static list of terminals is used
          // to determine what terminal to use.
          terminal: Some("${config.preferences.apps.terminal}"),
        )
      '';
    };
  }
)
