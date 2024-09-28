# Thread model:
# My personal computers are listening on no ports. All connections are outbound.
# My personal computers may connect to unsecure networks.
# My personal computer may be left unattended.
# My personal computer needs most debugging and developement capabilities.
# My personal computer may be used by multiple users.

{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
let
  cfg = config.dotfiles.security.target;
in
{
  imports = [
    inputs.sops-nix.nixosModules.default
    # "${modulesPath}/profiles/hardened.nix"
    ./harden.nix
  ];

  config = lib.mkIf (cfg == "desktop") {
    #extra hardening 
    boot.kernel.sysctl = {
      # The Magic SysRq key is a key combo that allows users connected to the
      # system console of a Linux kernel to perform some low-level commands.
      # Disable it, since we don't need it, and is a potential security concern.
      "kernel.sysrq" = 0;
      # This setting is only meaningful on 64 bit architectures and will likely
      # break any 32 bit application. Luckily those no longer really exist.
      "abi.vsyscall32" = 0;
      # Disable automatic loading TTY line disciplines that rarely anyone uses
      "dev.tty.ldisc_autoload" = 0;
      # Ensure best practices when using file permissions
      "fs.protected_fifos" = 1;
      "fs.protected_regular" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      # dmesg  only concerns root
      "kernel.dmesg_restrict" = 1;
      # Protect ptrace at least a bit
      "kernel.yama.ptrace_scope" = 1;

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Incomplete protection again TIME-WAIT assassination
      "net.ipv4.tcp_rfc1337" = 1;

      ## TCP optimization
      # TCP Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
      # both incoming and outgoing connections:
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferbloat mitigations + slight improvement in throughput & latency
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
    };

    security = {
      sudo.execWheelOnly = true;

      tpm2 = {
        enable = true;
        abrmd.enable = true;
      };
      # I need sandboxes
      unprivilegedUsernsClone = lib.mkForce true;
      # Need it for no brain desktop services
      lockKernelModules = lib.mkForce false;
      #polkit
      polkit.enable = true;
    };
    services = {
      # smart card deamon
      pcscd.enable = true;
      #secure usb devices
      fwupd.enable = true;
      usbguard = {
        enable = true;
        dbus.enable = true;
        restoreControllerDeviceState = true;
        ruleFile = config.sops.secrets.usbguard-rules.path;
      };
      # antivirus
      # enable antivirus clamav and
      # keep the signatures' database updated
      clamav = {
        daemon.enable = true;
        updater.enable = true;
      };
    };

    environment = {

      # Undo setting memory allocator to 'scudo'.
      # 'scudo' breaks the usage of firefox.
      memoryAllocator.provider = lib.mkForce "libc";
      systemPackages = [
        inputs.sops-nix.packages.${pkgs.stdenv.system}.default
        pkgs.pcscliteWithPolkit
      ];
    };

    # create system-wide executables firefox
    # that will wrap the real binaries so everything
    # work out of the box.
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        floorp = {
          executable = lib.getExe pkgs.floorp;
          profile = "${pkgs.firejail}/etc/firejail/floorp.profile";
        };
        thunderbird = {
          executable = lib.getExe pkgs.thunderbird;
          profile = "${pkgs.firejail}/etc/firejail/thunderbird.profile";
        };
        mpv = {
          executable = "${lib.getBin pkgs.mpv}/bin/mpv";
          profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
        };
      };
    };

    systemd.coredump.enable = false;
  };
}
