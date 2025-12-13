{pkgs, lib, ...}: let
in {
  imports = [./pandoc];

  config = {
    home.packages = with pkgs; [
      #ms-office to text conversion tool
      catdoc

      #collection of utilities for indexing and searching Maildirs
      mu

      #svg and png editing
      inkscape
      gimp

      # office
      libreoffice-still

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
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
