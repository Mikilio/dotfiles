{
  config,
  lib,
  options,
  pkgs,
  osConfig ? null,
  ...
}: let
  inherit (lib) mkIf mkOption;

  cfg = config.programs.herdr;

  facterReport =
    if osConfig != null && osConfig ? hardware.facter && osConfig.hardware.facter ? report
    then osConfig.hardware.facter.report
    else {};

  # nixos-facter reports smbios memory device sizes in KiB. The board's
  # `memory_array.max_size` is deliberately ignored: it is the maximum the
  # board accepts, not the memory actually installed.
  installedMemoryKiB =
    lib.foldl' (total: device: total + (device.size or 0)) 0
    (lib.attrByPath ["smbios" "memory_device"] [] facterReport);

  # Truncating division keeps the ceiling at or below the requested percentage.
  derivedMemoryMax =
    if installedMemoryKiB == 0
    then null
    else "${toString (lib.div (installedMemoryKiB * 1024 * cfg.memoryMaxPercent) (100 * 1024 * 1024))}M";

  memoryMax =
    if cfg.memoryMax != null
    then cfg.memoryMax
    else derivedMemoryMax;

  attachScript = pkgs.writeShellApplication {
    name = "herdr-attach";
    runtimeInputs = [cfg.package pkgs.coreutils];
    text = ''
      # Fallback matches programs.herdr.socketPath for shells started without it.
      socket_path="''${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
      export HERDR_SOCKET_PATH="$socket_path"
      if [ -S "$socket_path" ] && timeout 5 ${lib.getExe cfg.package} api snapshot >/dev/null 2>&1; then
        exec ${lib.getExe cfg.package}
      fi
      exec ${lib.getExe pkgs.bashInteractive}
    '';
  };

  # A user unit starts before any shell has sourced the profile, so the wrapper
  # sources it rather than taking the user manager's environment.
  serveScript = pkgs.writeShellApplication {
    name = "herdr-serve";
    runtimeInputs = [cfg.package];
    text = ''
      # 2>/dev/null drops the `tty` diagnostic from GPG_TTY=$(tty).
      # shellcheck disable=SC1091
      . "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh" 2>/dev/null
      exec ${lib.getExe cfg.package} server
    '';
  };
in {
  options.programs.herdr = {
    socketPath = mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/herdr/herdr.sock";
      description = ''
        The unix socket the Herdr server listens on. Exported to the session
        and to the user manager, so the server, the shells and every client
        agree on it.
      '';
    };

    attachCommand = mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "${attachScript}/bin/herdr-attach";
      description = ''
        Command a terminal should run to attach to the session server. It
        attaches when the server answers and falls back to a shell otherwise.
        Set to null to opt out.
      '';
    };

    memoryLow = mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "1G";
      description = "The modest memory protection assigned to the Herdr slice.";
    };

    memoryMax = mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The hard memory ceiling for the Herdr slice. When null, the ceiling is
        derived from the machine's installed memory as reported by
        nixos-facter, which the NixOS configuration exposes to Home Manager as
        `osConfig.hardware.facter.report`.
      '';
    };

    memoryMaxPercent = mkOption {
      type = lib.types.ints.between 1 100;
      default = 50;
      description = ''
        Percentage of installed memory used as the Herdr slice ceiling when
        `programs.herdr.memoryMax` is null. Only used when a hardware report
        is available.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = memoryMax != null;
        message = ''
          programs.herdr.memoryMax could not be derived: no memory was found in
          osConfig.hardware.facter.report. Set programs.herdr.memoryMax
          explicitly, or point hardware.facter.reportPath at a report from
          nixos-facter.
        '';
      }
    ];

    # The socket path lives in the profile for both shells and the serve wrapper.
    home.sessionVariables.HERDR_SOCKET_PATH = cfg.socketPath;

    # The server binds the socket itself and nothing else is guaranteed to have
    # created the directory before the user manager reaches default.target.
    home.activation.createHerdrSocketDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$(dirname ${lib.escapeShellArg cfg.socketPath})"
    '';

    # A slice rather than the service, so the ceiling and the oomd policy also
    # cover anything else placed alongside the server later.
    systemd.user.slices.herdr = {
      Unit.Description = "Herdr session slice";
      Slice =
        {
          MemoryAccounting = true;
          ManagedOOMMemoryPressure = "kill";
          ManagedOOMPreference = "avoid";
        }
        // lib.optionalAttrs (cfg.memoryLow != null) {MemoryLow = cfg.memoryLow;}
        // lib.optionalAttrs (memoryMax != null) {MemoryMax = memoryMax;};
    };

    systemd.user.services.herdr = {
      Unit.Description = "Herdr session server";
      Service = {
        Type = "exec";
        ExecStart = "${serveScript}/bin/herdr-serve";
        Slice = "herdr.slice";
        Restart = "on-failure";
        RestartSec = 1;
        OOMPolicy = "continue";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
