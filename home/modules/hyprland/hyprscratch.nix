{
  inputs,
  pkgs,
  ...
}: let
  hyprscratch = inputs.hyprscratch.packages.${pkgs.stdenv.system}.default;
in {
  wayland.windowManager.hyprland.settings = {
    exec-once = ["${hyprscratch}/bin/hyprscratch clean"];

    bind = [
      ''SUPER, s, exec, ${hyprscratch}/bin/hyprscratch "Spotify Premium" "[float;size 70% 80%;center] spotify" onstart special''
      ''SUPER, t, exec, ${hyprscratch}/bin/hyprscratch Telegram "[float;size 70% 80%;center] telegram-desktop" onstart special''
      ''SUPER, m, exec, ${hyprscratch}/bin/hyprscratch "Teams for Linux" "[float;size 70% 80%;center] teams-for-linux" onstart special''
      ''SUPER, d, exec, ${hyprscratch}/bin/hyprscratch Discord "[float;size 70% 80%;center] vesktop" special''
      ''SUPER, e, exec, ${hyprscratch}/bin/hyprscratch Element "[float;size 70% 80%;center] element-desktop" special''
      ''SUPER, o, togglespecialworkspace, OBS''
    ];

    windowrulev2 = let
      f = regex: "float,initialTitle:^(${regex})$";
      s = regex: "size 70% 80%,initialTitle:^(${regex})$";
      c = regex: "center,initialTitle:^(${regex})$";
      scratchpads = [
        "Spotify Premium"
        "Telegram"
        "Discord"
        "Element"
        "OBS"
        "Teams for Linux"
      ];
    in
      (map f scratchpads)
      ++ (map s scratchpads)
      ++ (map c scratchpads)
      ++ [
        "workspace special:Discord silent ,initialTitle:^(Discord)$"
        "workspace special:OBS silent ,initialTitle:^OBS.*?$"
        "workspace special:OBS silent ,initialTitle:^Mumble.*?$"
      ];
  };
}
