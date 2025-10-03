{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.exec-once = [
    # Uncomment these if needed
    # "$terminal"
    # "nm-applet &"
    # "waybar & hyprpaper & vivaldi"
  ];
}

