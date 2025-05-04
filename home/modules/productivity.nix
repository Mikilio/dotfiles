{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
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
      calibre

      #curcuits
      # kicad

      #durov <3
      telegram-desktop
      #ZUCK
      whatsapp-for-linux

      #tor <3
      tor-browser

      #mumble
      mumble

      #Calendar
      morgen

      #10xorganization
      logseq
      glibc #https://github.com/logseq/logseq/issues/10851

      #need it for work
      vesktop
      brave
      slack
      teams-for-linux
      # zoom-us

      #matrix
      element-desktop

      #science
      zotero

      #ftp
      filezilla

      #for testing
      zen-browser
    ];
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
