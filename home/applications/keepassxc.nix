{inputs, moduleWithSystem} : moduleWithSystem (
perSystem@{ inputs' }:
{ config
, lib
, pkgs
, ...
}:

with lib;

let

in {
  config = {
    assertions = [
      (hm.assertions.assertPlatform "services.keepassxc" pkgs platforms.linux)
    ];

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "keepassxc password manager";
        BusName= "org.freedesktop.secrets";
        Wants = [ "tray.target" ];
        Requires = [ "sops-nix.service" ];
        After = [ "sops-nix.service" "tray.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = ["xdg-desktop-autostart.target"];

      Service = {
        Type = "exec";
        Restart = "on-abnormal";
        ExecStart = "/bin/sh -c '${pkgs.keepassxc}/bin/keepassxc --pw-stdin ${config.xdg.userDirs.publicShare}/Passwords.kdbx < ${config.sops.secrets.keepassxc.path}'";
      };
    };
  };
})
