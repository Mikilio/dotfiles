{
  config,
  pkgs,
  inputs,
  ...
}: {
  # greetd display manager
  services.greetd = let
    kaizen = inputs.kaizen.packages.${pkgs.stdenv.system}.default;
  in {
    enable = true;
    settings.default_session.command = pkgs.writeShellScript "greeter" ''
      export XKB_DEFAULT_LAYOUT=${config.services.xserver.xkb.layout}
      export XCURSOR_THEME=Qogir
      ${kaizen}/bin/kaizen-dm
    '';
  };
  systemd.tmpfiles.rules = [
    "d '/var/cache/greeter' - greeter greeter - -"
  ];

  system.activationScripts.wallpaper = let
    wp = pkgs.writeShellScript "wp" ''
      CACHE="/var/cache/greeter"
      OPTS="$CACHE/options.json"
      HOME="/home/$(find /home -maxdepth 1 -printf '%f\n' | tail -n 1)"

      mkdir -p "$CACHE"
      chown greeter:greeter $CACHE

      if [[ -f "$HOME/.cache/ags/options.json" ]]; then
        cp $HOME/.cache/ags/options.json $OPTS
        chown greeter:greeter $OPTS
      fi

      if [[ -f "$HOME/.config/background" ]]; then
        cp "$HOME/.config/background" $CACHE/background
        chown greeter:greeter "$CACHE/background"
      fi
    '';
  in
    builtins.readFile wp;

  services.udev.extraRules = ''
    ACTION=="remove",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    ACTION=="add",\
     ENV{ID_BUS}=="usb",\
     ENV{ID_MODEL_ID}=="0407",\
     ENV{ID_VENDOR_ID}=="1050",\
     ENV{ID_VENDOR}=="Yubico",\
     RUN+="${pkgs.systemd}/bin/loginctl unlock-sessions"
  '';

  security.pam = {
    u2f = {
      enable = true;
      cue = true;
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock.u2fAuth = true;
    };
  };
}
