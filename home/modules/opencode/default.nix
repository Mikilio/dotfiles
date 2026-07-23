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

      Example:
        {
          CONTEXT7_API_KEY = "rbw get context7-api-key";
          ANTHROPIC_API_KEY = "op read op://Personal/Anthropic/api_key";
        }
    '';
    example = {
      CONTEXT7_API_KEY = "rbw get context7-api-key";
    };
  };

  config = let
    exports = lib.mapAttrsToList (n: v: "export ${n}=\"$(${v} | tr -d '\\n')\"") config.programs.opencode.environments;
  in
    {
      programs = {
        opencode = {
          enable = true;
          package = pkgs.writeShellScriptBin "opencode" ''
            ${lib.strings.concatLines exports}
            exec ${pkgs.systemd}/bin/systemd-run \
              --user \
              --scope \
              --collect \
              -- ${lib.getExe pkgs.opencode} "$@"
          '';
          enableMcpIntegration = true;
          extraPackages = with pkgs; [
          ];
        };
        mcp = {
          enable = true;
          servers = {
            playwright = {
              command = "docker";
              args = ["run" "-i" "--rm" "--init" "--pull=always" "mcr.microsoft.com/playwright/mcp"];
            };
            context7 = {
              url = "https://mcp.context7.com/mcp";
              headers = {
                CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
              };
            };
            github = {
              url = "https://api.githubcopilot.com/mcp/readonly";
              headers = {
                Authorization = "Bearer {env:GITHUB_PAT}";
              };
            };
          };
        };
      };
    }
    // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
    {
      home.persistence = {
        "/persistent/storage" = {
          directories = [
            {
              directory = ".local/share/opencode";
              mode = "0700";
            }
          ];
        };
        "/persistent/cache" = {
          directories = [
            {
              directory = ".config/opencode";
              mode = "0700";
            }
          ];
        };
      };
    };
}
