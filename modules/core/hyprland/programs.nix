{ config, pkgs, ... }:

{
  programs.hyprland.settings = {
    "$terminal" = "ghostty";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$browser" = "firefox";
  };
}

