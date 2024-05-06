{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: {
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

        #vpn
        eduvpn-client

        #durov <3
        telegram-desktop

        #tor <3
        tor-browser

        #mumble
        mumble

        xterm

        discord-canary
        #matrix
        element-desktop

      ];
      dconf.settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      };
    };
  }
)
