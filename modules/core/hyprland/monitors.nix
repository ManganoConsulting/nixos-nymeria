{ config, pkgs, ... }:

{
  programs.hyprland.settings = {
    monitor = [
      ", preferred, auto, auto"   
      # "eDP-1, disable"
    ];
  };
}
