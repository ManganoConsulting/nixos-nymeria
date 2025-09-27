{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
  };

  # Define environment variables
  environment.variables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };
}

