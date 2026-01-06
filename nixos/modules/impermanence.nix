{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  config = {
    fileSystems."/persistent/storage".neededForBoot = true;
    fileSystems."/persistent/cache".neededForBoot = true;
    #usefulness disputed
    fileSystems."/persistent/volatile".neededForBoot = true;
    fileSystems."/var/lib/sops-nix".neededForBoot = true;

    boot = {
      # Allow installation to change EFI variables
      loader.efi.canTouchEfiVariables = true;
      # Minimal list of modules to use the EFI system partition and the YubiKey
      initrd = {
        kernelModules = [
          "vfat"
          "nls_cp437"
          "nls_iso8859-1"
          "usbhid"
        ];
        # Enable support for the YubiKey PBA
        #luks.yubikeySupport = true;

        # Clean root on reboot
        systemd.services.rollback = {
          description = "Rollback root filesystem to a pristine state on boot";
          wantedBy = [
            "initrd.target"
          ];
          after = [
            "cryptsetup.target"
          ];
          before = [
            "sysroot.mount"
          ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir /btrfs_tmp
            mount /dev/mapper/crypted /btrfs_tmp
            if [[ -e /btrfs_tmp/root ]]; then
                mkdir -p /btrfs_tmp/old_roots
                timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
                mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
            fi

            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/btrfs_tmp/$i"
                done
                btrfs subvolume delete "$1"
            }

            for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
                delete_subvolume_recursively "$i"
            done

            btrfs subvolume create /btrfs_tmp/root
            umount /btrfs_tmp
          '';
        };
      };
    };

    #Impermanence
    environment.persistence = {
      "/persistent/storage" = {
        enable = true; # NB: Defaults to true, not needed
        hideMounts = true;
        directories = [
          "/var/lib/btrfs"
          "/var/lib/systemd"
          "/var/lib/sops-nix"
        ];
      };
      "/persistent/cache" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
        ];
      };
    };
  };
}
