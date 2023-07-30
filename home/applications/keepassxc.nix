{
  config,
  lib,
  pkgs,
  flakePath,
  ...
}:
with lib; let
  cfg = config.home.applications;
in {
  config = mkIf cfg.passwords {
    assertions = [
      (hm.assertions.assertPlatform "services.keepassxc" pkgs platforms.linux)
    ];

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "keepassxc password manager";
        Requires = ["sops-nix.service"];
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Install = {WantedBy = ["graphical-session.target"];};

      Service = {
        Type = "exec";
        Restart = "no";
        ExecStart = "/bin/sh -c '${pkgs.keepassxc}/bin/keepassxc --pw-stdin ${flakePath}/secrets/Passwords.kdbx < ${config.sops.secrets.keepassxc.path}'";
      };
    };
  };
}
