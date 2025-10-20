{
  inputs,
  config,
  osConfig,
  ...
}: {
  imports = [inputs.neovix.homeManagerModules.default];
  config = {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      vimdiffAlias = true;
      plugins.lsp.servers.nixd.settings.options = let
        flake = ''builtins.getFlake "${../..}"'';
      in {
        nixos.expr = ''(${flake}).nixosConfigurations.${osConfig.networking.hostName}.options'';
        home.expr = ''(${flake}).nixosConfigurations."${config.home.username}@${osConfig.networking.hostName}".options'';
      };
    };
    stylix.targets.nixvim.plugin = "base16-nvim";
  };
}
