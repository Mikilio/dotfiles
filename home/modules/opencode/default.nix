{
  pkgs,
  lib,
  config,
  options,
  ...
}: {
  config = {
    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        context = ''
          You are running on NixOS. Key facts:

          - You have access to all nix CLI commands.
          - If a tool or package is missing, install it impermanently with `nix-shell -p <package> --run "..."` or `nix run nixpkgs#<package> -- ...`. Do not attempt to use package managers like apt, dnf, or brew.
          - If a command fails because a binary is missing, reach for nix first.

          All dependencies you care about are likely in the nix store. Always use the nix CLI to discover them.
          DO NOT search or query the nix store with any unix commands.
        '';
      };
      mcp = {
        enable = true;
        servers = {
          playwright = {
            enabled = false;
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
          openspec
          nono
          pi-coding-agent
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
