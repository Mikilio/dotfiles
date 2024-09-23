{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./client.nix
  ];
  options.dotfiles.networking = {
    enable = pkgs.lib.mkOptional "Networking Settings";
    target = lib.mkOption {
      default = "client";
      example = "server";
      description = "What kind of device is this intended for?";
      type = lib.types.str;
    };
  };
}

