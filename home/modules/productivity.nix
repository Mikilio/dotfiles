{
  options,
  pkgs,
  lib,
  ...
}: let
in {
  imports = [./pandoc];

  config = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
    home =
      {
        packages = with pkgs; [
          #ms-office to text conversion tool
          catdoc

          #collection of utilities for indexing and searching Maildirs
          mu

          #svg and png editing
          inkscape
          gimp

          # office
          libreoffice

          # 3d modelling
          blender

          # books
          # calibre

          #curcuits
          # kicad

          #durov <3
          telegram-desktop
          #ZUCK
          wasistlos

          #tor <3
          tor-browser

          #mumble
          mumble

          #Calendar
          morgen

          #10xorganization
          obsidian
          pdfannots2json
          tesseract
          glibc #https://github.com/logseq/logseq/issues/10851

          #need it for work
          vesktop
          slack
          teams-for-linux
          # zoom-us

          #matrix
          element-desktop

          #science
          zotero

          #ftp
          filezilla
        ];
      }
      // lib.optionalAttrs (builtins.hasAttr "persistence" options.home)
      {
        persistence = {
          "/persistent/storage" = {
            directories = [
              "Zotero"
              ".pki"
              ".zotero"
              ".local/share/calibre-ebook.com"
              ".local/share/TelegramDesktop"
              ".local/share/wasistlos"

              #exceptions
              ".config/libreoffice"
              ".config/rclone"
              ".config/obs-studio"
            ];
          };
          "/persistent/cache" = {
            directories = [
              #Electron mess
              ".config/Morgen"
              ".config/obsidian"
              ".config/Element"
              ".config/teams-for-linux"
              ".config/wasistlos"
              ".config/vesktop"

              #actual caches
              ".cache/vfs"
              ".cache/vfsMeta"
              ".cache/wasistlos"
            ];
          };
        };
      };
  };
}
