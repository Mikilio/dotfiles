{ config, lib, ... }:
let
  users = config.users.users;
  admins =
    with builtins;
    filter (user: elem "wheel" (getAttr user users).extraGroups) (attrNames users);
  devDirs = map (admin: "/home/${admin}/Code") admins;

in
{
  systemd = lib.mkIf (config.specialisation != {}) {

    targets.machines.enable = true;
    services."systemd-nspawn@ubuntu" = {
      enable = true;
      wantedBy = [ "machines.target" ];
      overrideStrategy = "asDropin";
    };
    nspawn = {
      "ubuntu" = {
        enable = true;
        execConfig = {
          Boot = true;
          ResolvConf = "copy-host";
        };

        filesConfig = {
          # Bind home usefull for dev
          Bind = devDirs;
        };
        networkConfig = {
          Private = false;
        };
      };
      "arch" = {
        enable = true;
        execConfig = {
          Boot = true;
          ResolvConf = "copy-host";
        };

        filesConfig = {
          # Bind home usefull for dev
          Bind = devDirs;
        };
        networkConfig = {
          Private = false;
        };
      };
    };
  };
}
