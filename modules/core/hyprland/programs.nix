{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "ghostty";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$browser" = "vivaldi";
  };
}
