{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./desktop.nix
  ];
  options.dotfiles.security = {
    enable = pkgs.lib.mkOptional "Security Settings";
    target = lib.mkOption {
      default = "desktop";
      example = "server";
      description = "What kind of device is this intended for?";
      type = lib.types.str;
    };
  };
}
