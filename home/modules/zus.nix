{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    programs.rclone = {
      enable = true;
      package = pkgs.nur.repos.mikilio.rclone_zus;
      remotes.vult = {
        config = {
          type = "zus";
          allocation_id = "22947daa03d9874cbb1e1ff23cb8fddabd0734b854e639254229102374566f62";
          encrypt = true;
        };
        mounts = {
          "Encrypted/Documents" = {
            mountPoint = config.xdg.userDirs.documents;
            options = {
              dir-cache-time = "6h";
              attr-timeout = "2s";
              poll-interval = "30s";
              vfs-cache-max-size = "20G";
              vfs-cache-max-age = "7d";
            };
          };
          "Encrypted/Pictures" = {
            mountPoint = config.xdg.userDirs.pictures;
            options = {
              dir-cache-time = "12h";
              attr-timeout = "5s";
              poll-interval = "1m";
              vfs-cache-max-size = "50G";
              vfs-cache-max-age = "14d";
            };
          };
          "Encrypted/Videos" = {
            mountPoint = config.xdg.userDirs.videos;
            options = {
              dir-cache-time = "24h";
              attr-timeout = "10s";
              poll-interval = "5m";
              vfs-cache-max-size = "100G";
              vfs-cache-max-age = "30d";
            };
          };
          "Encrypted/Music".mountPoint = config.xdg.userDirs.music;
          "Public" = {
            mountPoint = config.xdg.userDirs.publicShare;
            options = {
              dir-cache-time = "5m";
              attr-timeout = "1s";
              poll-interval = "15s";
              vfs-cache-max-size = "10G";
              vfs-cache-max-age = "1d";
            };
          };
        };
      };
    };
  };
}
