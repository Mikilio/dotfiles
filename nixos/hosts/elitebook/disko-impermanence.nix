{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  config = {
    #required for impermanence
    fileSystems."/persistent".neededForBoot = true;

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
      "/persistent" = {
        enable = true; # NB: Defaults to true, not needed
        hideMounts = true;
        directories = [
          "/var/lib/btrfs"
          "/var/lib/systemd"
          "/var/lib/sops-nix"
        ];
        # users.mikilio = {
        #   directories = [
        #     "Desktop"
        #     "Code"
        #     "Downloads"
        #     "Zotero"
        #     ".floorp/Default"
        #     ".floorp/PWA"
        #     ".thunderbird/default"
        #     ".pki"
        #     ".steam"
        #     ".yubico"
        #     ".zcn"
        #     ".zen"
        #     ".zotero"
        #     ".local/state"
        #     ".local/share/applications"
        #     ".local/share/atuin"
        #     ".local/share/calibre-ebook.com"
        #     ".local/share/com.yubico.yubioath"
        #     ".local/share/containers"
        #     ".local/share/devenv"
        #     ".local/share/direnv"
        #     ".local/share/gnupg"
        #     ".local/share/nix"
        #     ".local/share/nvim"
        #     ".local/share/password-store"
        #     ".local/share/sioyek"
        #     ".local/share/Steam"
        #     ".local/share/TelegramDesktop"
        #     ".local/share/tmux"
        #     ".local/share/Trash"
        #     ".local/share/wasistlos"
        #     ".local/share/zoxide"
        #
        #     #exceptions
        #     ".config/Morgen"
        #     ".config/rclone"
        #     ".config/obsidian"
        #     ".cache/spotify"
        #     ".cache/vfs"
        #     ".cache/vfsMeta"
        #     ".cache/wasistlos"
        #   ];
        #   files = [
        #     ".ssh/known_hosts"
        #   ];
        # };
      };
      "/persistent/cache" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
        ];
      };
    };

    #Disko
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                  ];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  extraOpenArgs = [];
                  askPassword = true;
                  settings = {
                    # preLVM = true;
                    # yubikey = {
                    #   slot = 2;
                    #   twoFactor = false;
                    #   storage = {
                    #     device = "$EFI_PART";
                    #   };
                    # };
                    crypttabExtraOpts = ["tpm2-device=auto"];
                    allowDiscards = true;
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/persistent" = {
                        mountpoint = "/persistent";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
