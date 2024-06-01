{
  config,
  lib,
  ...
}: {
  # greetd display manager
  services.greetd = let
    session = {
      command = "${lib.getExe config.programs.hyprland.package}";
      user = "mikilio";
    };
  in {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = session;
      initial_session = session;
    };
  };
  # security.pam = {
  #   u2f = {
  #     enable = true;
  #     cue = true;
  #     authFile = config.sops.secrets.u2f_mappings.path;
  #   };
  #   services = {
  #     login.u2fAuth = true;
  #   };
  # };
}
