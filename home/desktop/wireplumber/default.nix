{...}:{...}: {
  config = {
    systemd.user.targets.sound = {
      Install.WantedBy = [ "graphical-session.target"];
      Unit = {
        Requires = [
          "pipewire.service"
          "wireplumber.service"
          "easyeffects.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };
    };
  };
}
