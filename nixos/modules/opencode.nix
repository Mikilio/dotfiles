{
  config,
  lib,
  pkgs,
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
  };

  config = {
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

    systemd.services.opencode = {
      description = "Opencode AI server";
      wantedBy = ["multi-user.target"];
      path = with pkgs; [
        nix
        git
        file
        curl
        gnutar
        podman
      ];
      environment = {
        inherit (config.environment.variables) NIX_PATH;
      };

      serviceConfig = {
        Type = "simple";
        User = "opencode";
        Group = "opencode";
        ExecStart = "${cfg.package}/bin/opencode serve --port ${toString cfg.port} --hostname 127.0.0.1";

        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateDevices = true;
        RestrictNetworkInterfaces = ["~mycelium" "~wg0"];
        # NoNewPrivileges = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        Delegate = "yes";
        ProtectProc = "invisible";

        IPAddressDeny = "all";
        IPAddressAllow = "127.0.0.1";

        RuntimeDirectory = "opencode";
        StateDirectory = "opencode";
        CacheDirectory = "opencode";

        BindReadOnlyPaths = [
          "/var/run/docker.sock"
        ];
      };
    };
  };
}
