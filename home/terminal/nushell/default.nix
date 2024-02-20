{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: hm @ {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
    in {
      config = {
        programs.nushell = {
          enable = true;
          shellAliases =
            config.home.shellAliases
            // {
              eza = mkForce "ls";
              lt = mkForce "br -s";
              mkdir = mkForce "mkdir";
              hm = mkForce "echo";
            };
        };
      };
    }
)
