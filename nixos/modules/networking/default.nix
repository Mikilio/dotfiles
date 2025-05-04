{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop.nix
  ];
  options.dotfiles.networking = {
    enable = pkgs.lib.mkOptional "Networking Settings";
    target = lib.mkOption {
      default = null;
      example = "server";
      description = "What kind of device is this intended for?";
      type = lib.types.nullOr lib.types.str;
    };
    IPv6Identity = lib.mkOption {
      default = null;
      example = "2a01:4f8:aaaa:bbbb::1/64";
      description = "IPv6 address of this host";
      type = lib.types.nullOr lib.types.str;
    };
    #currently only considering hosts with one NIC
    physicalInterface = lib.mkOption {
      default = null;
      example = "eth0";
      description = "Name of the physical interface on the host";
      type = lib.types.nullOr lib.types.str;
    };
  };
}
