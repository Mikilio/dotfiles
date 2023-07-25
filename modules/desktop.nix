{
  inputs',
  pkgs,
  self,
  ...
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
      mscore-ttf

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
      # for Rocket League
      allowedTCPPortRanges = [
        {
          from = 27015;
          to = 27030;
        }
        {
          from = 27036;
          to = 27037;
        }
      ];
      allowedUDPPorts = [4380 27036 34197];
      allowedUDPPortRanges = [
        {
          from = 7000;
          to = 9000;
        }
        {
          from = 27000;
          to = 27031;
        }
      ];

      # Spotify track sync with other devices
      allowedTCPPorts = [57621];
    };
  };

  nix = {
    # package = inputs'.nix-super.packages.nix;
    settings = {
      substituters = [
        "https://nix-gaming.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.privatevoid.net"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
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
    udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  };

  # allow wayland lockers to unlock the screen
  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
        auth optional ${pkgs.pam_gnupg}/lib/security/pam_gnupg.so
      '';
    };

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
  /* systemd.user.services = { */
  /*   xdg-desktop-portal-wlr.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Sway"; */
  /*   xdg-desktop-portal-hyprland.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland"; */
  /* }; */

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
