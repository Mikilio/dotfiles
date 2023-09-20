#!/bin/sh

handle() {
  case $1 in
    minimize*)
      IFS="," read -r address minimized <<< "$2"
      if [ "$minimized" -eq 1 ]; then
        hyprctl dispatch movetoworkspacesilent "special:tray,address:0x$(cut -c 2- <<< "$address")"
      else
        hyprctl dispatch togglefloating "$(cut -c 2- <<< "$address")"
      fi
      ;;
  esac
}

socat -U  - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | \
  while IFS=">" read -r type args; do handle "$type" "$args"; done
