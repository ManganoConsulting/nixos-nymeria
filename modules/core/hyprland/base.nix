{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
  };

  # Hyprland-friendly Wayland environment
  environment.variables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "warp-terminal";
  };

  # XDG portals for screen share / file pickers under Hyprland
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];
}
