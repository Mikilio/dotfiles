{ ... }:
{
  # Allow installation to change EFI variables
  boot.loader.efi.canTouchEfiVariables = true;
  # Minimal list of modules to use the EFI system partition and the YubiKey
  boot.initrd.kernelModules = [
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
    "usbhid"
  ];
  # Enable support for the YubiKey PBA
  # boot.initrd.luks.yubikeySupport = true;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
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
                extraOpenArgs = [ ];
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
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
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
}
