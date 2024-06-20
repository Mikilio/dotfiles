{...}: let
  restartAgs = ''hyprshell -b hypr quit; hyprctl dispatch exec -- hyprshell -b hypr'';
in {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.0;
              status = "enable";
            }
          ];
          exec = restartAgs;
        };
      }
      {
        profile = {
          name = "home_office";
          outputs = [
            {
              criteria = "Samsung Electric Company LS32A600U HNTR700259";
              position = "0,0";
              adaptiveSync = true;
              scale = 1.0;
              mode = "2560x1440@75";
            }
          ];
          exec = restartAgs;
        };
      }
      {
        profile = {
          name = "home_combo";
          outputs = [
            {
              criteria = "Samsung Electric Company LS32A600U HNTR700259";
              position = "0,0";
              adaptiveSync = true;
              scale = 1.0;
              mode = "2560x1440@75";
            }
            #NOTE:make the laptop screen usable when wezterm accepts scales bigger thatn 1
            {
              criteria = "eDP-1";
              scale = 1.0;
            }
          ];
          exec = restartAgs;
        };
      }
    ];
  };
}
