{
  config,
  inputs,
  ...
}: {
  imports = [inputs.walker.homeManagerModules.default];

  programs.walker = {
    enable = true;
    runAsService = true;

    # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
    config = {
      force_keyboard_focus = true;
      resume_last_query = true;
      theme = "stylix";
    };

    # Set `programs.walker.config.theme="your theme name"` to choose the default theme
    themes.stylix = {
      # modified from https://github.com/abenz1267/walker/blob/master/resources/themes/default/style.css
      style = let
        inherit (config.stylix.generated) palette;
      in
        #css
        ''
          @define-color window_bg_color #${palette.base00};
          @define-color accent_bg_color #${palette.base0D};
          @define-color theme_fg_color  #${palette.base05};
          @define-color error_bg_color #C34043;
          @define-color error_fg_color #DCD7BA;

          * {
            all: unset;
          }

          popover {
            background: lighter(@window_bg_color);
            border: 1px solid darker(@accent_bg_color);
            border-radius: 18px;
            padding: 10px;
          }

          .normal-icons {
            -gtk-icon-size: 16px;
          }

          .large-icons {
            -gtk-icon-size: 32px;
          }

          scrollbar {
            opacity: 0;
          }

          .box-wrapper {
            box-shadow:
              0 19px 38px rgba(0, 0, 0, 0.3),
              0 15px 12px rgba(0, 0, 0, 0.22);
            background: @window_bg_color;
            padding: 20px;
            border-radius: 20px;
            border: 1px solid darker(@accent_bg_color);
          }

          .preview-box,
          .elephant-hint,
          .placeholder {
            color: @theme_fg_color;
          }

          .box {
          }

          .search-container {
            border-radius: 10px;
          }

          .input placeholder {
            opacity: 0.5;
          }

          .input selection {
            background: lighter(lighter(lighter(@window_bg_color)));
          }

          .input {
            caret-color: @theme_fg_color;
            background: lighter(@window_bg_color);
            padding: 10px;
            color: @theme_fg_color;
          }

          .input:focus,
          .input:active {
          }

          .content-container {
          }

          .placeholder {
          }

          .scroll {
          }

          .list {
            color: @theme_fg_color;
          }

          child {
          }

          .item-box {
            border-radius: 10px;
            padding: 10px;
          }

          .item-quick-activation {
            background: alpha(@accent_bg_color, 0.25);
            border-radius: 5px;
            padding: 10px;
          }

          /* child:hover .item-box, */
          child:selected .item-box,
          row:selected .item-box {
            background: alpha(@accent_bg_color, 0.25);
          }

          .item-text-box {
          }

          .item-subtext {
            font-size: 12px;
            opacity: 0.5;
          }

          .providerlist .item-subtext {
            font-size: unset;
            opacity: 0.75;
          }

          .item-image-text {
            font-size: 28px;
          }

          .preview {
            border: 1px solid alpha(@accent_bg_color, 0.25);
            /* padding: 10px; */
            border-radius: 10px;
            color: @theme_fg_color;
          }

          .calc .item-text {
            font-size: 24px;
          }

          .calc .item-subtext {
          }

          .symbols .item-image {
            font-size: 24px;
          }

          .todo.done .item-text-box {
            opacity: 0.25;
          }

          .todo.urgent {
            font-size: 24px;
          }

          .todo.active {
            font-weight: bold;
          }

          .bluetooth.disconnected {
            opacity: 0.5;
          }

          .preview .large-icons {
            -gtk-icon-size: 64px;
          }

          .keybinds {
            padding-top: 10px;
            border-top: 1px solid lighter(@window_bg_color);
            font-size: 12px;
            color: @theme_fg_color;
          }

          .global-keybinds {
          }

          .item-keybinds {
          }

          .keybind {
          }

          .keybind-button {
            opacity: 0.5;
          }

          .keybind-button:hover {
            opacity: 0.75;
          }

          .keybind-bind {
            text-transform: lowercase;
            opacity: 0.35;
          }

          .keybind-label {
            padding: 2px 4px;
            border-radius: 4px;
            border: 1px solid @theme_fg_color;
          }

          .error {
            padding: 10px;
            background: @error_bg_color;
            color: @error_fg_color;
          }

          :not(.calc).current {
            font-style: italic;
          }

          .preview-content.archlinuxpkgs,
          .preview-content.dnfpackages {
            font-family: monospace;
          }
        '';
    };
  };

  wayland.windowManager.hyprland.settings = {
    bindr = [
      "$mod, SPACE, exec, nc -U /run/user/1000/walker/walker.sock"
    ];
    layerrule = [
      "blur on, ignore_alpha 0.5, animation fade, match:namespace walker"
    ];
  };
}
