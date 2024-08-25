{pkgs, config, ...}: let
in {
  config = {
    programs.password-store = {
      enable = true;
      package = pkgs.pass-wayland.withExtensions (
        exts:
          with exts; [
            pass-otp
            pass-file
            pass-audit
            pass-update
            pass-import
          ]
      );
    };
    programs.browserpass.enable = true;
    services.pass-secret-service = {
      enable = true;
      storePath = "${config.home.homeDirectory}/.local/share/password-store";

    };
  };
}
