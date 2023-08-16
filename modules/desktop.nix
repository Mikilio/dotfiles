{ config
, inputs'
,  pkgs
,  self
,  ...
}: {
  fonts = {
    fonts = with pkgs; [
      # icon fonts
      material-symbols

      # normal fonts
      jost
      lexend
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      roboto
      config.nur.repos.mikilio.ttf-ms-fonts

      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
    ];

    # make fonts accesible to wrapped applications
    fontDir.enable = true;

    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };

  hardware.opengl = {
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # enable location service
  location.provider = "geoclue2";

  networking = {
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        57621 # Spotify track sync with other devices
        2099 # League of Legends PVP.Net
        8088 # LoL Spectator
      ];
      allowedTCPPortRanges = [
        {
          #League of Legends PVP.NEt
          from = 5222;
          to = 5223;
        }
        {
          # League of Legends Patcher
          from = 8393;
          to = 8400;
        }
      ];
      allowedUDPPorts = [
        8088 # LoL Spectator
        8080 # Local-Live-Serve
      ];
      allowedUDPPortRanges = [
        # League of Legends
        {
          from = 5000;
          to = 5500;
        }
      ];
    };
  };

  services = {
    # use Ambient Light Sensors for auto brightness adjustment
    clight = {
      enable = true;
      settings = {
        verbose = true;
        dpms.timeouts = [900 300];
        dimmer.timeouts = [870 270];
        screen.disabled = true;
      };
    };

    pcscd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

    psd = {
      enable = true;
      resyncTimer = "10m";
    };

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = [pkgs.gcr];
    gvfs.enable = true;
    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
      #yubikey support
      yubikey-personalization
    ];
  };

  security = {
    # userland niceness
    rtkit.enable = true;
  };

  programs = {
    # enable hyprland and required options
    hyprland = {
      enable = true;
      package = inputs'.hyprland.packages.hyprland;
    };
    steam.enable = true;
    #necessary for some programs that rely on gsettings
    dconf.enable = true;
  };

  #start only the correct portals (this is sufficient for systemd but dbus will still look for wlr because of well known names)
  /*
  systemd.user.services = {
  */
  /*
  xdg-desktop-portal-wlr.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Sway";
  */
  /*
  xdg-desktop-portal-hyprland.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
  */
  /*
  };
  */

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
