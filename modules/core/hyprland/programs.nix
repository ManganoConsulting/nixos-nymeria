{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "warp-terminal";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$browser" = "vivaldi";
  };
}
