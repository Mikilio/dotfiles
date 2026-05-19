{
  inputs,
  pkgs,
  lib,
  options,
  ...
}: {
  programs.neovim.defaultEditor = true;
  home =
    {
      packages = [inputs.neovix.packages.${pkgs.stdenv.hostPlatform.system}.default];
      sessionVariables = {
        EDITOR = "vi";
        VISUAL = "vi";
      };
    }
    // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
    {
      persistence."/persistent/storage" = {
        directories = [
          {
            directory = ".local/share/nvim";
            mode = "0700";
          }
        ];
      };
    };
}
