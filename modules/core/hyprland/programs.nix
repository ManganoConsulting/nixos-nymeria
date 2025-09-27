{ config, pkgs, ... }:

{
  programs.hyprland.settings = {
    "$terminal" = "warp-terminal";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$browser" = "firefox";
  };
}
