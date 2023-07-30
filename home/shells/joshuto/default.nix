{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.home.shells.joshuto;
in {
  config = mkIf cfg {
    home.packages = [pkgs.joshuto];

    xdg.configFile = {
      "joshuto/joshuto.toml".source = ./joshuto.toml;
      "joshuto/keymap.toml".source = ./keymap.toml;
      "joshuto/mimetype.toml".source = ./mimetype.toml;
      "joshuto/theme.toml".source = ./theme.toml;
      "joshuto/icons.toml".source = ./icons.toml;
      "joshuto/preview_file.sh" = {
        source = ./preview_file.sh;
        executable = true;
      };
    };

    /*
    xdg.desktopEntries = {
    */
    /*
    joshuto = {
    */
    /*
    name = "Files";
    */
    /*
    comment = "Access and organize files";
    */
    /*
    exec = "joshuto %u";
    */
    /*
    icon = "system-file-manager";
    */
    /*
    terminal = true;
    */
    /*
    type = "Application";
    */
    /*
    startupNotify = false;
    */
    /*
    categories = [ "Utility" "Core" "FileManager" "System" "FileTools" ];
    */
    /*
    mimeType= [ "inode/directory" ];
    */
    /*
    };
    */
    /*
    };
    */
  };
}
