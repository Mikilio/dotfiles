# A profile with most (vanilla) hardening options enabled by default,
# potentially at the cost of stability, features and performance.
#
# This profile enables options that are known to affect system
# stability. If you experience any stability issues when using the
# profile, try disabling it. If you report an issue and use this
# profile, always mention that you do.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.dotfiles.security.target;
in
{
  config = lib.mkIf (cfg != null) {

    boot.kernelPackages = mkDefault pkgs.linuxKernel.packages.linux_hardened;

    nix.settings.allowed-users = mkDefault [ "@users" ];

    environment.memoryAllocator.provider = mkDefault "scudo";
    environment.variables.SCUDO_OPTIONS = mkDefault "ZeroContents=1";

    security.lockKernelModules = mkDefault true;

    security.protectKernelImage = mkDefault true;

    security.forcePageTableIsolation = mkDefault true;

    # This is required by podman to run containers in rootless mode.
    security.unprivilegedUsernsClone = mkDefault config.virtualisation.docker.rootless.enable;

    security.virtualisation.flushL1DataCache = mkDefault "always";

    security.apparmor.enable = mkDefault true;
    security.apparmor.killUnconfinedConfinables = mkDefault true;

    security.sudo.execWheelOnly = mkDefault true;

    boot.kernelParams = [
      # Don't merge slabs
      "slab_nomerge"

      # Overwrite free'd pages
      # "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"

      # Disable debugfs
      "debugfs=off"

      # better than just disabling smt
      "mitigations=auto,nosmt"
    ];

    boot.blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    boot.kernel.sysctl = {
      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = mkOverride 500 2;

      # JIT hardening for unprivileged users only (to eliminate spray attacks)
      "net.core.bpf_jit_harden" = mkDefault 1;

      # Disable ftrace debugging
      "kernel.ftrace_enabled" = mkDefault false;

      # Enable strict reverse path filtering (that is, do not attempt to route
      # packets that "obviously" do not belong to the iface's network; dropped
      # packets are logged as martians).
      "net.ipv4.conf.all.log_martians" = mkDefault true;
      "net.ipv4.conf.all.rp_filter" = mkDefault "1";
      "net.ipv4.conf.default.log_martians" = mkDefault true;
      "net.ipv4.conf.default.rp_filter" = mkDefault "1";

      # Ignore broadcast ICMP (mitigate SMURF)
      "net.ipv4.icmp_echo_ignore_broadcasts" = mkDefault true;

      # Ignore incoming ICMP redirects (note: default is needed to ensure that the
      # setting is applied to interfaces added after the sysctls are set)
      "net.ipv4.conf.all.accept_redirects" = mkDefault false;
      "net.ipv4.conf.all.secure_redirects" = mkDefault false;
      "net.ipv4.conf.default.accept_redirects" = mkDefault false;
      "net.ipv4.conf.default.secure_redirects" = mkDefault false;
      "net.ipv6.conf.all.accept_redirects" = mkDefault false;
      "net.ipv6.conf.default.accept_redirects" = mkDefault false;

      # Ignore outgoing ICMP redirects (this is ipv4 only)
      "net.ipv4.conf.all.send_redirects" = mkDefault false;
      "net.ipv4.conf.default.send_redirects" = mkDefault false;
    };
  };
}
