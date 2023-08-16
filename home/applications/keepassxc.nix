{
  config,
  lib,
  pkgs,
  flakePath,
  ...
}:
with lib; let
  cfg = config.preferences.apps;
in {
  config = mkIf cfg.passwords {
    assertions = [
      (hm.assertions.assertPlatform "services.keepassxc" pkgs platforms.linux)
    ];

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "keepassxc password manager";
        Requires = ["sops-nix.service"];
        After = ["sops-nix.service"];
      };

      Install = {WantedBy = ["graphical-session.target"];};

      Service = {
        Type = "exec";
        Restart = "on-abnormal";
        ExecStart = "/bin/sh -c '${pkgs.keepassxc}/bin/keepassxc --pw-stdin ${config.xdg.userDirs.publicShare}/Passwords.kdbx < ${config.sops.secrets.keepassxc.path}'";
      };
    };
  };
}
