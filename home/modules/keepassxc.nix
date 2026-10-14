{
  inputs,
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  config = {
    assertions = [
      (hm.assertions.assertPlatform "services.keepassxc" pkgs platforms.linux)
      {
        assertion = options ? sops && config.sops.secrets ? keepassxc;
        message = ''
          The keepassxc module needs a sops secret called `keepassxc` holding
          your database password, because it is fed to keepassxc at startup via
          `sops.secrets.keepassxc.path`.
        '';
      }
    ];

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "keepassxc password manager";
        Wants = ["tray.target"];
        Requires = ["sops-nix.service"];
        After = ["sops-nix.service" "tray.target"];
        PartOf = ["graphical-session.target"];
      };

      Install.WantedBy = ["xdg-desktop-autostart.target"];

      Service = {
        Type = "exec";
        Restart = "on-abnormal";
        ExecStart = "/bin/sh -c '${pkgs.keepassxc}/bin/keepassxc --pw-stdin ${config.xdg.userDirs.publicShare}/Passwords.kdbx < ${config.sops.secrets.keepassxc.path}'";
      };
    };
  };
}
