{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./desktop.nix
    ./harden.nix
    ./server.nix
  ];
  options.dotfiles.security = {
    target = lib.mkOption {
      default = null;
      example = "server";
      description = "What kind of device is this intended for?";
      type = lib.types.nullOr lib.types.str;
    };
  };
}
