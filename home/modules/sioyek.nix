{
  config,
  lib,
  ...
}: {
  config = {
    xdg.mimeApps.defaultApplicationPackages = [config.programs.sioyek.package];
    programs.sioyek = {
      enable = true;
      config = {
        "startup_commands" = lib.mkForce ["fit_page_to_width" "toggle_custom_color"];
        "start_with_helper_window" = "1";
      };
    };
  };
}
