{
  inputs,
  moduleWithSystem,
}:
moduleWithSystem (
  perSystem @ {inputs'}: hm @ {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
    in {
      config = {
        programs.password-store = {
          enable = true;
          package = pkgs.pass.withExtensions (exts:
            with exts; [
              pass-otp
              pass-file
              pass-audit
              pass-update
              pass-import
            ]);
          settings = {
            PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
          };
        };
        services.pass-secret-service = {
          enable = true;
        };
      };
    }
)
