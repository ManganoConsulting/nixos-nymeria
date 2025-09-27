{ pkgs, ... }:

{
  imports = [
    ./hyprland/base.nix
    ./hyprland/monitors.nix
    ./hyprland/autostart.nix
    ./hyprland/programs.nix
    ./hyprland/appearance.nix
    ./hyprland/animations.nix
    ./hyprland/input.nix
    ./hyprland/keybindings.nix
    ./hyprland/windowrules.nix
  ];
}
