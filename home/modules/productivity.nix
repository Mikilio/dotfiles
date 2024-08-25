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

      # office
      libreoffice-still

      # 3d modelling
      blender

      #curcuits
      kicad

      #vpn
      eduvpn-client

      #durov <3
      telegram-desktop

      #tor <3
      tor-browser

      #mumble
      mumble

      #10xorganization
      logseq
      glibc #https://github.com/logseq/logseq/issues/10851

      #need it for work
      vesktop
      teams-for-linux

      #matrix
      element-desktop

      #science
      zotero
    ];
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
