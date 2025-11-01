{
  lib,
  pkgs,
  ...
}: {
  services.shikane = {
    enable = true;
    settings = {
      profile = [
        {
          name = "ext-gpu";
          output = [
            {
              enable = false;
              match = "eDP-1";
            }
            {
              enable = false;
              search = [
                "m=LS32A600U"
                "s=HNTR700259"
                "v=Samsung Electric Company"
              ];
            }
            {
              adaptive_sync = true;
              enable = true;
              mode = "preferred";
              position = "0,0";
              scale = 1;
              search = [
                "m=LS32A600U"
                "s=HNTR700259"
                "v=Samsung Electric Company"
              ];
              transform = "normal";
            }
          ];
        }
        {
          name = "home-office";
          output = [
            {
              enable = false;
              match = "eDP-1";
            }
            {
              enable = true;
              mode = "preferred";
              position = "0,0";
              scale = 1;
              search = "/.*";
            }
          ];
        }
        {
          name = "pre-eject";
          output = [
            {
              enable = true;
              mode = "preferred";
              position = "0,0";
              scale = 1;
              match = "eDP-1";
            }
            {
              enable = false;
              search = "/.*";
            }
          ];
        }
        {
          name = "default";
          output = [
            {
              enable = true;
              mode = "preferred";
              position = "0,0";
              scale = 1;
              match = "eDP-1";
            }
          ];
        }
      ];
    };
  };
}
