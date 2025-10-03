{ config, pkgs, ... }:
{
  imports = [
    ../../modules/core/hyprland/appearance.nix
    ../../modules/core/hyprland/animations.nix
    ../../modules/core/hyprland/autostart.nix
    ../../modules/core/hyprland/input.nix
    ../../modules/core/hyprland/keybindings.nix
    ../../modules/core/hyprland/monitors.nix
    ../../modules/core/hyprland/programs.nix
    ../../modules/core/hyprland/windowrules.nix
  ];

  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # Enable Hyprland config under Home Manager
  wayland.windowManager.hyprland.enable = true;

  # User-level tooling and shell configs
  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Default editor/user session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "warp-terminal";
  };

  # Match NixOS release used for this home config
  home.stateVersion = "25.05";
}
