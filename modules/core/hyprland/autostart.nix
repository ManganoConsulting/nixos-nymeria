{ config, pkgs, ... }:

{
  programs.hyprland.settings.exec-once = [
    # Uncomment these if needed
    # "$terminal"
    # "nm-applet &"
    # "waybar & hyprpaper & firefox"
  ];
}

