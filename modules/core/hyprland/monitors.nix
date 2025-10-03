{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      ", preferred, auto, auto"   
      # "eDP-1, disable"
    ];
  };
}
