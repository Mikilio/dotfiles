{
  pkgs,
  lib,
  config,
  options,
  ...
}: {
  options.programs.opencode.environments = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = ''
      Environment variables to set for OpenCode, where the value is a command
      that outputs the environment variable value (without trailing newline).
    '';
    example = {
      ANTHROPIC_API_KEY = "op read op://Personal/Anthropic/api_key";
    };
  };

  config = let
    exports = lib.mapAttrsToList (n: v: "export ${n}=\"$(${v} | tr -d '\\n')\"") config.programs.opencode.environments;
  in {
    programs = {
      opencode = {
        enable = true;
        package = pkgs.writeShellScriptBin "opencode" ''
          ${lib.strings.concatLines exports}
          exec ${pkgs.systemd}/bin/systemd-run \
            --user \
            --service-type=exec \
            --unit=opencode-$$ \
            --collect \
            --working-directory="$(pwd)" \
            --property=ProtectSystem=strict \
            --property="TemporaryFileSystem=/home:ro" \
            --property=PrivateTmp=true \
            --property=PrivateDevices=true \
            --property=NoNewPrivileges=true \
            --property=ProtectProc=invisible \
            --property=ProtectKernelTunables=true \
            --property=ProtectKernelModules=true \
            --property=RestrictRealtime=true \
            --property=RestrictSUIDSGID=true \
            '--property=RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK' \
            --property=BindReadOnlyPaths=/nix/store \
            --property="BindReadOnlyPaths=''${XDG_CONFIG_HOME:-$HOME/.config}/opencode" \
            --property=BindPaths=/var/run/docker.sock \
            --property="BindPaths=$(pwd)" \
            -- ${lib.getExe pkgs.opencode} "$@"
        '';
        enableMcpIntegration = true;
        extraPackages = with pkgs; [
          nix
        ];
        context = ''
          You are running on NixOS inside a systemd sandbox. Key facts:

          - You have access to all nix CLI commands.
          - If a tool or package is missing, install it impermanently with `nix-shell -p <package> --run "..."` or `nix run nixpkgs#<package> -- ...`. Do not attempt to use package managers like apt, dnf, or brew.
          - The filesystem is mostly read-only. Only your current working directory is writable.
          - You do NOT have access to host ports or listening services. You cannot bind to ports.
          - Docker is available via the socket at `/var/run/docker.sock`.
          - The internet is accessible for outbound connections only.
          - If a command fails because a binary is missing, reach for nix first.

          All dependencies you care about are likely in the nix store. Always use the nix CLI to discover them.
          DO NOT search or query the nix store with any unix commands.
        '';
      };
      mcp = {
        enable = true;
        servers = {
          playwright = {
            command = "docker";
            args = ["run" "-i" "--rm" "--init" "--pull=always" "mcr.microsoft.com/playwright/mcp"];
          };
        };
      };
    };
    home =
      {
        packages = with pkgs; [
          mgrep
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence."/persistent/cache" = {
          directories = [
            {
              directory = ".local/share/opencode";
              mode = "0700";
            }
          ];
        };
      };
  };
}
