{
  config,
  theme,
  pkgs,
  ...
}: let
  inherit (theme) colors;

  pointer = config.home.pointerCursor;
  home = config.home.homeDirectory;
  terminal = config.home.sessionVariables.TERM;
  launcher = "anyrun";
  eventd = pkgs.writeShellApplication {
    name = "eventd";
    runtimeInputs = [pkgs.socat];
    text = builtins.readFile ./scripts/event.sh;
  };
  drun = pkgs.writeShellScriptBin "drun" ''
    exec ${pkgs.systemd}/bin/systemd-run \
      --slice=app-manual.slice \
      --property=ExitType=cgroup \
      --user \
      --wait \
      bash -lc "exec $@"
  '';
in {
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER

    # start hyprpaper
    exec-once = hyprpaper

    # set cursor for HL itself
    exec-once = hyprctl setcursor ${pointer.name} ${toString pointer.size}

    #cliphist
    exec-once = wl-paste --type text --watch cliphist store #Stores only text data
    exec-once = wl-paste --type image --watch cliphist store #Stores only image data

    # special workspace for minimized windows
    workspace = special:tray
    exec-once = ${drun} ${eventd}/bin/eventd

    #monitor setups:
    #homestation
    monitor=DP-1, 1920x1080, 0x0, 1
    monitor=DP-2, 1920x1080, 1920x0, 1

    # use this instead of hidpi patches
    xwayland {
      force_zero_scaling = true
    }

    misc {
      # disable auto polling for config file changes
      disable_autoreload = true
      # disable dragging animation
      animate_mouse_windowdragging = false
      # enable variable refresh rate (effective depending on hardware)
      vrr = 1
    }

    general {
      gaps_out = 5
      border_size = 2
      col.active_border = rgb(${colors.blue}) rgb(${colors.mauve}) 270deg
      col.inactive_border = rgb(${colors.crust}) rgb(${colors.lavender}) 270deg

      # group borders
      col.group_border_active = rgb(${colors.pink})
      col.group_border = rgb(${colors.surface0})
    }

    input {
      numlock_by_default = true
      accel_profile = "flat"
      follow_mouse = 2
    }

    decoration {
      rounding = 16

      blur {
        enabled = true
        size = 3
        passes = 1
      }

      shadow_offset = 0 5
      shadow_range = 50
      shadow_render_power = 3
      col.shadow = rgba(00000099)
    }

    animations {
      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    dwindle {
      # keep floating dimentions while tiling
      pseudotile = true
      preserve_split = true
    }

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    #make keepass windows always floating
    windowrulev2 = float, class:^(org.keepassxc.KeePassXC)$

    # xwaylandvideobridge
    windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
    windowrulev2 = noanim,class:^(xwaylandvideobridge)$
    windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
    windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$

    # special workspace work obs preview
    windowrulev2 = workspace name:󰹑  silent, title:^(Windowed Projector \(Preview\))$
    windowrulev2 = fullscreen, title:^(Windowed Projector \(Preview\))$

    # make PiP window floating and sticky
    windowrulev2 = float, title:^(Picture-in-Picture)$
    windowrulev2 = pin, title:^(Picture-in-Picture)$

    # start vivaldi in ws2
    windowrulev2 = workspace 2 silent, class:^(vivaldi-stable)$
    windowrulev2 = monitor DP-2, class:^(vivaldi-stable)$

    # start termina in ws2
    windowrulev2 = workspace 1 silent, class:^(Alacritty)$
    windowrulev2 = monitor DP-1, class:^(Alacritty)$

    # start spotify tiled in ws9
    windowrulev2 = tile, title:^(Spotify)$
    windowrulev2 = workspace 9 silent, title:^(Spotify)$
    windowrulev2 = monitor DP-2, title:^(Spotify)$

    # start Discord/WebCord in ws0
    windowrulev2 = workspace 10 silent, title:^(.*(Disc|WebC)ord.*)$
    windowrulev2 = monitor DP-2, title:^(.*(Disc|WebC)ord.*)$

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
    windowrulev2 = idleinhibit focus, class:^(vivaldi-stable)$, title:^(.*YouTube.*)$
    windowrulev2 = idleinhibit fullscreen, class:^(vivaldi-stable)$

    # fix xwayland apps
    windowrulev2 = rounding 0, xwayland:1, floating:1
    windowrulev2 = fullscreen, class:^(league of legends.exe)$
    windowrulev2 = forceinput, class:^(league of legends.exe)$
    windowrulev2 = float, class:^(leagueclientux.exe)$
    windowrulev2 = center, class:^(leagueclientux.exe)$

    layerrule = blur, ^(gtk-layer-shell|anyrun)$
    layerrule = ignorezero, ^(gtk-layer-shell|anyrun)$

    # mouse movements
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
    bindm = $mod ALT, mouse:272, resizewindow

    # compositor commands
    bind = $mod SHIFT, E, exec, pkill Hyprland
    bind = $mod, Q, killactive,
    bind = $mod, F, fullscreen,
    bind = $mod, G, togglegroup,
    bind = $mod SHIFT, N, changegroupactive, f
    bind = $mod SHIFT, P, changegroupactive, b
    bind = $mod, R, togglesplit,
    bind = $mod, T, togglefloating,
    bind = $mod, P, pseudo,
    bind = $mod ALT, ,resizeactive,
    # toggle "monocle" (no_gaps_when_only)
    $kw = dwindle:no_gaps_when_only
    bind = $mod, M, exec, hyprctl keyword $kw $(($(hyprctl getoption $kw -j | jaq -r '.int') ^ 1))

    # utility
    # launcher
    bindr = $mod, Space, exec, pkill ${launcher} || ${launcher}
    # terminal
    bind = $mod, Return, exec, ${terminal}
    # logout menu
    bind = $mod, Escape, exec, wlogout -p layer-shell
    # lock screen
    bind = $mod, L, exec, loginctl lock-session
    # select area to perform OCR on
    bind = $mod, O, exec, wl-ocr

    # move focus
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    # window resize
    bind = $mod, S, submap, resize

    submap = resize
    binde = , right, resizeactive, 10 0
    binde = , left, resizeactive, -10 0
    binde = , up, resizeactive, 0 -10
    binde = , down, resizeactive, 0 10
    bind = , escape, submap, reset
    submap = reset

    # media controls
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous
    bindl = , XF86AudioNext, exec, playerctl next

    # volume
    bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 5%+
    binde = , XF86AudioRaiseVolume, exec, ${home}/.config/eww/scripts/volume osd
    bindle = , XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 5%-
    binde = , XF86AudioLowerVolume, exec, ${home}/.config/eww/scripts/volume osd
    bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bind = , XF86AudioMute, exec, ${home}/.config/eww/scripts/volume osd
    bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # backlight
    bindle = , XF86MonBrightnessUp, exec, brillo -q -u 300000 -A 5
    binde = , XF86MonBrightnessUp, exec, ${home}/.config/eww/scripts/brightness osd
    bindle = , XF86MonBrightnessDown, exec, brillo -q -u 300000 -U 5
    binde = , XF86MonBrightnessDown, exec, ${home}/.config/eww/scripts/brightness osd

    #color-picker
    bind = $mod, C, exec, hyprpicker -a


    # screenshot
    # stop animations while screenshotting; makes black border go away
    $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
    bind = , Print, exec, $screenshotarea
    bind = $mod SHIFT, R, exec, $screenshotarea

    bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
    bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output

    bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
    bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen

    # workspaces
    # binds mod + [shift +] {1..10} to [move to] ws {1..10}
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # cycle workspaces
    bind = $mod, bracketleft, workspace, m-1
    bind = $mod, bracketright, workspace, m+1
  '';
}
