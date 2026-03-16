{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.opencode;
in {
  options.services.opencode = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
      description = "Opencode package to use";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "Port to listen on";
    };

    preset = lib.mkOption {
      type = lib.types.enum ["antigravity" "custom" "geminicli" "github"];
      default = "custom";
      description = "Which preset opencode.json to use from opencode-config";
    };
  };

  config = let
    configSource = "${inputs.opencode-config.outPath}/opencode.${cfg.preset}.example.json";
  in {
    users.users.opencode = {
      isSystemUser = true;
      group = "opencode";
      home = "/var/lib/opencode/";
      description = "Opencode AI service user";
      useDefaultShell = true;
      autoSubUidGidRange = true;
      extraGroups = ["docker"];
    };

    users.groups.opencode = {};

    environment.systemPackages = let
      wrapper = pkgs.writeShellScriptBin "opencode" ''
        exec ${cfg.package}/bin/opencode attach http://127.0.0.1:${toString cfg.port} "$@"
      '';
    in [wrapper];

    systemd.services.opencode = {
      description = "Opencode AI server";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = "opencode";
        Group = "opencode";
        ExecStart = "${cfg.package}/bin/opencode serve --port ${toString cfg.port} --hostname 127.0.0.1";

        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateDevices = true;
        NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProtectProc = "invisible";

        IPAddressDeny = "all";
        IPAddressAllow = "127.0.0.1";

        RuntimeDirectory = "opencode";
        StateDirectory = "opencode";
        CacheDirectory = "opencode";

        Environment = "OPENCODE_CONFIG_DIR=${configSource}";

        BindReadOnlyPaths = [
          "/var/run/docker.sock"
        ];
      };
    };
  };
}
